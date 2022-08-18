// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/ILockedGeist.sol";
import "./interfaces/ILendingPool.sol"; // we use 1 interface for gToken and gFTM

import "./interfaces/IUniswapRouter.sol";
import "./interfaces/IMasterChef.sol";



contract LiGeistStrategy is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    bool public incentiveForLP;

    uint256 public fee;
    address public treasury;

    address public lockedGeist;
    address public geist;
    address public liGeistManager;
    address public gftmGateway;

    address public geistLendingPool; // used for any gToken except gFTM
    address public gestLendingWETH; //used for gFTM
    address public gFTM;            // we need to know gftm because of wETH gateway
    address public gUSDC;
    address public USDC;

    address public constant NATIVE = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public tokenRewardForChef;
    address public liGeistChef;
    address public lpChef;
    address public router;

    address[] public geistRewards;  // gTokens
    address[] public geistRewardsUnderlying;    // underlying gTokens (gDAI -> DAI)

    mapping(address => bool) public isStrategy;

    constructor() public {}

    function initialize(address _geist, address _lockedGeist, address _gFTM, address _gUSDC, address _USDC, address _gftmGateway/*, address _tokenRewardForChef*/) public initializer {
        __Ownable_init();

        geist = _geist;
        lockedGeist = _lockedGeist;

        gFTM = _gFTM;
        geistRewards.push(gFTM);
        geistRewardsUnderlying.push(NATIVE);
        gftmGateway = _gftmGateway;
        geistLendingPool = address(0x9FAD24f572045c7869117160A571B2e50b10d068);

        gUSDC = _gUSDC;
        USDC = _USDC;
        geistRewards.push(gUSDC);
        geistRewardsUnderlying.push(USDC);
        tokenRewardForChef = _gUSDC;

        incentiveForLP = true;

    }

    modifier restricted {
        require(msg.sender == owner() || msg.sender == liGeistManager, "Auth failed");
        _;
    }

    modifier onlyOwnerOrStrategy {
        require(msg.sender == owner() || isStrategy[msg.sender], "Permission denied");
        _;
    }

  
    function createLock(uint256 _amount) external restricted {
        uint256 _balance = IERC20Upgradeable(geist).balanceOf(address(this));
        require(_amount <= _balance, "Amount exceeds geist balance");
        IERC20Upgradeable(geist).safeApprove(lockedGeist, 0);
        IERC20Upgradeable(geist).safeApprove(lockedGeist, _amount);
        ILockedGeist(lockedGeist).stake(_amount, true);
    }

    function increaseAmount(uint256 _amount) external restricted {
        uint256 _balance = IERC20Upgradeable(geist).balanceOf(address(this));
        require(_amount <= _balance, "Amount exceeds geist balance");
        IERC20Upgradeable(geist).safeApprove(lockedGeist, 0);
        IERC20Upgradeable(geist).safeApprove(lockedGeist, _amount);
        ILockedGeist(lockedGeist).stake(_amount, true);
    }


    function withdrawaExpiredLocksTo(address _to) external onlyOwner {
        uint256 _balBefore = IERC20Upgradeable(geist).balanceOf(address(this));
        ILockedGeist(lockedGeist).withdrawExpiredLocks();

        uint256 _balAfter = IERC20Upgradeable(geist).balanceOf(address(this));
        require(_balAfter > _balBefore, "withdraw = 0");

        IERC20Upgradeable(geist).safeTransfer(_to, _balAfter.sub(_balBefore));
    }

    function withdrawAndRelock() external onlyOwner{
        uint256 _balBefore = IERC20Upgradeable(geist).balanceOf(address(this));
        ILockedGeist(lockedGeist).withdrawExpiredLocks();
        
        uint256 _newBalToLock = IERC20Upgradeable(geist).balanceOf(address(this));
        require(_newBalToLock > _balBefore, "withdraw = 0");

        IERC20Upgradeable(geist).safeApprove(lockedGeist, 0);
        IERC20Upgradeable(geist).safeApprove(lockedGeist, _newBalToLock);
        ILockedGeist(lockedGeist).stake(_newBalToLock, true);
    }


    // claim geist reward, convert everything to USDC
    function claimRewards() external onlyOwnerOrStrategy {
        
        uint256 i = 0;
        uint256 _balanceTemp;
        uint256 _balanceUnderlying;
        address[] memory path = new address[](2);


        ILockedGeist(lockedGeist).getReward();

        for(i; i < geistRewards.length; i++){
            // check if we have gFTM
            _balanceTemp = IERC20Upgradeable(geistRewards[i]).balanceOf(address(this));

            if(geistRewards[i] == gFTM && _balanceTemp > 1e18){
                IERC20Upgradeable(gFTM).safeApprove(gftmGateway, 0);
                IERC20Upgradeable(gFTM).safeApprove(gftmGateway, uint256(-1));
                ILendingPool(gftmGateway).withdrawETH(geistLendingPool, _balanceTemp, address(this));

                _balanceUnderlying = address(this).balance;
                path[1] = USDC;
                path[0] = NATIVE;
                IUniswapRouter(router).swapExactETHForTokens{value: _balanceUnderlying}(0, path, address(this), block.timestamp);

            } 
            else if (geistRewards[i] != gFTM && geistRewards[i] != gUSDC && _balanceTemp > 0) {

                IERC20Upgradeable(geistRewards[i] ).safeApprove(geistLendingPool, 0);
                IERC20Upgradeable(geistRewards[i] ).safeApprove(geistLendingPool, _balanceTemp);
                ILendingPool(geistLendingPool).withdraw(geistRewardsUnderlying[i], _balanceTemp, address(this));

                path[0] = geistRewardsUnderlying[i];
                path[1] = NATIVE;
                _balanceUnderlying = IERC20Upgradeable(geistRewardsUnderlying[i]).balanceOf(address(this));

                IERC20Upgradeable(path[0]).safeApprove(router, 0);
                IERC20Upgradeable(path[0]).safeApprove(router, _balanceUnderlying);
                IUniswapRouter(router).swapExactTokensForTokens(_balanceUnderlying, 0, path, address(this), block.timestamp);
            }

            else {
                //we give away gUSDC
            }
            
            
            // SWAP rewards to WFTM

        }

        // GET USDC
        path[0] = NATIVE;
        path[1] = USDC;
        _balanceTemp = IERC20Upgradeable(NATIVE).balanceOf(address(this));
        IERC20Upgradeable(path[0]).safeApprove(router, 0);
        IERC20Upgradeable(path[0]).safeApprove(router, _balanceTemp);
        IUniswapRouter(router).swapExactTokensForTokens(_balanceTemp,0, path, address(this), block.timestamp);

        // GET gUSDC
        _balanceTemp = IERC20Upgradeable(USDC).balanceOf(address(this));
        
        IERC20Upgradeable(USDC).safeApprove(geistLendingPool, 0);
        IERC20Upgradeable(USDC).safeApprove(geistLendingPool, _balanceTemp);
        ILendingPool(geistLendingPool).deposit(USDC, _balanceTemp, address(this), 0);

        _balanceTemp = IERC20Upgradeable(tokenRewardForChef).balanceOf(address(this));
        uint256 feeAmount = _balanceTemp.mul(fee).div(1000);
        uint256 _liGeistStakersBalance = _balanceTemp.sub(feeAmount);
        IERC20Upgradeable(tokenRewardForChef).safeTransfer(liGeistChef, _liGeistStakersBalance);


        // if lp incentive send feeAmount to chef, else to treasury. Update chef distro time given the bool
        if(incentiveForLP){
            IERC20Upgradeable(tokenRewardForChef).safeTransfer(lpChef, feeAmount);
            IMasterChef(liGeistChef).setDistributionRate(_liGeistStakersBalance.add(feeAmount));
        } else {
            IERC20Upgradeable(tokenRewardForChef).safeTransfer(treasury, feeAmount);
            IMasterChef(liGeistChef).setDistributionRate(_liGeistStakersBalance);
        }
        

    }


    /*
        SETTERS
    */

    function setGeistLeningPool(address _address) external onlyOwner{
        geistLendingPool = _address;
    }

    function setIncentiveLp(bool _set) external onlyOwner {
        require(_set != incentiveForLP, 'already set');
        incentiveForLP = _set;
    }

    function setTreasury(address _address) external onlyOwner{
        treasury = _address;
    }
    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, 'nax fee');
        require(fee != _fee, 'same fee');
        fee = _fee;

    }
    function setRouter(address _router) external onlyOwner {
        require(_router != address(0), "addr zero");
        router = _router;
    }

    function setLPChef(address _lpChef) external onlyOwner {
        require(_lpChef != address(0), "addr zero");
        lpChef = _lpChef;
    }

    function setLiGeistChef(address _liGeistChef) external onlyOwner {
        require(_liGeistChef != address(0), "addr zero");
        liGeistChef = _liGeistChef;
    }

    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0), "addr zero");
        liGeistManager = _manager;
    }

    function whitelistStrategy(address _strategy) external onlyOwner {
        require(_strategy != address(0), "addr zero");
        isStrategy[_strategy] = true;
    }

    function blacklistStrategy(address _strategy) external onlyOwner {
        require(_strategy != address(0), "addr zero");
        isStrategy[_strategy] = false;
    }

    // for GEIST token, underlyingToken == geist
    function addGeistReward(address _token, address _underlyingToken) external onlyOwner {
        uint256 _totTokens = geistRewards.length;
        uint256 i = 0;
        if(_totTokens > 0){
            for(i; i < _totTokens; i++){
                require(geistRewards[i] != _token,"already in");
            }
        }

        geistRewards.push(_token);
        geistRewardsUnderlying.push(_underlyingToken);
    }

    function removeGeistReward(address _token) external onlyOwner {
        uint256 i;
        uint256 _tot = geistRewards.length;
        bool flag = false;

        //check last pos first
        if(geistRewards[_tot -1] == _token){
            geistRewards.pop();
            geistRewardsUnderlying.pop();
            flag = true;
        }
        else {
            for(i=0; i < _tot; i++){
                if(geistRewards[i] == _token){
                    geistRewards[i] = geistRewards[_tot - 1];
                    geistRewards.pop();
                    geistRewardsUnderlying[i] = geistRewardsUnderlying[_tot - 1]; 
                    geistRewardsUnderlying.pop();
                    flag = true;
                }
            }

        }
        require(flag == true, "not found");
    }


    function removeGeistRewardAt(uint256 _pos) external onlyOwner{
        uint256 tot = geistRewards.length;
        require(_pos <= tot, "_pos too big");

        geistRewards[_pos] = geistRewards[tot - 1];
        geistRewards.pop();
        geistRewardsUnderlying[_pos] = geistRewardsUnderlying[tot - 1]; 
        geistRewardsUnderlying.pop();

    }

    function rewardTokenLen() external view returns(uint256){
        return geistRewards.length;
    }

    /*
        VIEW
    */

    function lockedBalances() view external returns (uint256 total, uint256 unlockable, uint256 locked, ILockedGeist.LockedBalance[] memory lockData) {
        (total, unlockable, locked, lockData) = ILockedGeist(lockedGeist).lockedBalances(address(this));
    }

    /*function setDelegate(address _delegateContract, address _delegate) external onlyOwner{
        IDelegation(_delegateContract).setDelegate("spiritswap.eth", _delegate);
    }

    function clearDelegate(address _delegateContract) external onlyOwner {
        IDelegation(_delegateContract).clearDelegate("spiritswap.eth");
    }*/

    function execute(address to, uint256 value, bytes calldata data) external onlyOwnerOrStrategy returns(bool, bytes memory)  {
        (bool success, bytes memory result) = to.call{value: value}(data);

        return (success, result);
    }

}