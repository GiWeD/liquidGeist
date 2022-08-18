// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@boringcrypto/boring-solidity/contracts/libraries/BoringMath.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./libraries/SignedSafeMath.sol";

import "./interfaces/IMasterChef.sol";
import "./interfaces/ISecondRewarder.sol";


contract LPChef is OwnableUpgradeable {
    using SafeMath for uint256;
    using BoringMath128 for uint128;
    using BoringERC20 for IERC20;
    using SignedSafeMath for int256;

    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        uint256 accRewardPerShare;
        uint256 lastRewardTime;
        uint256 allocPoint;
    }

    /// @notice Address of rewardToken contract.
    IERC20 public rewardToken;

    /// @notice Info of each MCV2 pool.
    PoolInfo[] public poolInfo;
    /// @notice Address of the LP token for each MCV2 pool.
    IERC20[] public lpToken;

    /// @notice Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    /// @dev Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    uint256 public rewardPerSecond;
    uint256 private ACC_rewardToken_PRECISION;

    // Deposit Fee Address
    address public feeAddress;

    uint256 public distributePeriod;
    uint256 public lastDistributedTime;

    /// @notice Address of each `ISecondRewarder` contract in MCV2.
    ISecondRewarder[] public rewarder;

    // allow external strat to set distribution rate
    mapping(address => bool) public externalAddr;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid,uint256 allocPoint,IERC20 indexed lpToken,ISecondRewarder indexed rewarder);
    event LogSetPool(uint256 indexed pid,uint256 allocPoint,ISecondRewarder indexed rewarder,bool overwrite);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event LogRewardPerSecond(uint256 rewardPerSecond);

    modifier ownerOrExternal {
        require(msg.sender == owner() || externalAddr[msg.sender] == true, 'notAllowed');
        _;
    }

    constructor() public {}

    function initialize(IERC20 _rewardToken) public initializer {
        __Ownable_init();
        rewardToken = _rewardToken;
        distributePeriod = 604800;
        ACC_rewardToken_PRECISION = 1e12;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
    }

    /// @notice Returns the number of MCV2 pools.
    function poolLength() public view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    /// @notice Add a new LP to the pool. Can only be called by the owner.
    /// DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    /// @param allocPoint AP of the new pool.
    /// @param _lpToken Address of the LP ERC-20 token.
    function add(uint256 allocPoint, IERC20 _lpToken, ISecondRewarder _rewarder) public onlyOwner {
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        lpToken.push(_lpToken);
        rewarder.push(_rewarder);

        poolInfo.push(PoolInfo({allocPoint: allocPoint, lastRewardTime: block.timestamp, accRewardPerShare: 0}));
        emit LogPoolAddition(lpToken.length.sub(1), allocPoint, _lpToken, _rewarder);
    }

    /// @notice Update the given pool's rewardToken allocation point and `IRewarder` contract. Can only be called
    /// by the owner.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    function set(uint256 _pid, uint256 _allocPoint, ISecondRewarder _rewarder, bool overwrite) public onlyOwner {
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;

        if (overwrite) {
            rewarder[_pid] = _rewarder;
        }

        emit LogSetPool(
            _pid, 
            _allocPoint,
            overwrite ? _rewarder : rewarder[_pid],
            overwrite
        );
    }

    /// @notice Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 len = poolInfo.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(i);
        }
    }

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerSecond The amount of Reward to be distributed per second.
    function setRewardPerSecond(uint256 _rewardPerSecond) public ownerOrExternal {
        rewardPerSecond = _rewardPerSecond;
        emit LogRewardPerSecond(_rewardPerSecond);
    }

    function setDistributionRate(uint256 amount) public onlyOwner {
        uint256 notDistributed;
        if (lastDistributedTime > 0 && block.timestamp < lastDistributedTime) {
            uint256 timeLeft = lastDistributedTime.sub(block.timestamp);
            notDistributed = rewardPerSecond.mul(timeLeft);
        }

        amount = amount.add(notDistributed);
        uint256 _rewardPerSecond = amount.div(distributePeriod);
        rewardPerSecond = _rewardPerSecond;
        lastDistributedTime = block.timestamp.add(distributePeriod);
        massUpdatePools();
        emit LogRewardPerSecond(_rewardPerSecond);
    }

    /// @notice View function to see pending rewardToken on frontend.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _user Address of user.
    /// @return pending rewardToken reward for a given user.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256 pending) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = lpToken[_pid].balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 time = block.timestamp.sub(pool.lastRewardTime);
            uint256 reward = time.mul(rewardPerSecond).mul(pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare.add(reward.mul(ACC_rewardToken_PRECISION) / lpSupply);
        }
        pending = int256(user.amount.mul(accRewardPerShare) / ACC_rewardToken_PRECISION).sub(user.rewardDebt).toUInt256();
    }

    /// @notice Update reward variables of the given pool.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @return pool Returns the pool that was updated.
    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[pid];
        if (block.timestamp > pool.lastRewardTime) {
            uint256 lpSupply = lpToken[pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 time = block.timestamp.sub(pool.lastRewardTime);
                uint256 reward = time.mul(rewardPerSecond).mul(pool.allocPoint) / totalAllocPoint;
                pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(ACC_rewardToken_PRECISION).div(lpSupply));
            }
            pool.lastRewardTime = block.timestamp;
            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardTime, lpSupply, pool.accRewardPerShare);
        }
    }

    /// @notice Deposit LP tokens to MCV2 for rewardToken allocation.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(
        uint256 pid,
        uint256 amount,
        address to
    ) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][to];

        // Effects
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.rewardDebt.add(int256(amount.mul(pool.accRewardPerShare) / ACC_rewardToken_PRECISION));

        ISecondRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onReward(pid, to, to, 0, user.amount);
        }

        lpToken[pid].safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, pid, amount, to);
    }

    /// @notice Withdraw LP tokens from MCV2.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(
        uint256 pid,
        uint256 amount,
        address to
    ) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];

        // Effects
        user.rewardDebt = user.rewardDebt.sub(int256(amount.mul(pool.accRewardPerShare) / ACC_rewardToken_PRECISION));
        user.amount = user.amount.sub(amount);

        ISecondRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onReward(pid, to, to, 0, user.amount);
        }

        lpToken[pid].safeTransfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of rewardToken rewards.
    function harvest(uint256 pid, address to) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedReward = int256(user.amount.mul(pool.accRewardPerShare) / ACC_rewardToken_PRECISION);
        uint256 _pendingReward = accumulatedReward.sub(user.rewardDebt).toUInt256();

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward != 0) {
            rewardToken.safeTransfer(to, _pendingReward);
        }

        ISecondRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onReward(
                pid,
                msg.sender,
                to,
                _pendingReward,
                user.amount
            );
        }

        emit Harvest(msg.sender, pid, _pendingReward);
    }

    /// @notice Withdraw LP tokens from MCV2 and harvest proceeds for transaction sender to `to`.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens and rewardToken rewards.
    function withdrawAndHarvest(
        uint256 pid,
        uint256 amount,
        address to
    ) public {
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedReward = int256(user.amount.mul(pool.accRewardPerShare) / ACC_rewardToken_PRECISION);
        uint256 _pendingReward = accumulatedReward.sub(user.rewardDebt).toUInt256();

        // Effects
        user.rewardDebt = accumulatedReward.sub(int256(amount.mul(pool.accRewardPerShare) / ACC_rewardToken_PRECISION));
        user.amount = user.amount.sub(amount);

        // Interactions
        rewardToken.safeTransfer(to, _pendingReward);

        ISecondRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onReward(
                pid,
                msg.sender,
                to,
                _pendingReward,
                user.amount
            );
        }

        lpToken[pid].safeTransfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
        emit Harvest(msg.sender, pid, _pendingReward);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(uint256 pid, address to) public {
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        ISecondRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onReward(pid, msg.sender, to, 0, 0);
        }

        // Note: transfer can fail or succeed if `amount` is zero.
        lpToken[pid].safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, pid, amount, to);
    }

    function setExternalAddr(address _external, bool value) external onlyOwner {
        require(_external != address(0), 'addr 0');
        externalAddr[_external] = value;
    }





}