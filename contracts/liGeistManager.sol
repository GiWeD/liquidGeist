// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/ILiGeistStrategy.sol";
import "./interfaces/ILiGeist.sol";

contract liGeistManager {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant geist = address(0xd8321AA83Fb0a4ECd6348D4577431310A6E0814d);

    address public feeManager;
    address public strategy;
    address public liGeist;
    address public owner;

    constructor(address _strategy, address _liGeist) public {
        strategy = _strategy;
        liGeist = _liGeist;
        feeManager = msg.sender;
        owner = msg.sender;
    }

    function initialLock(uint256 _amount) public {
        require(msg.sender == owner, "!auth");
        require(_amount > 0, "!>0");
        //lock immediately, transfer directly to strategy to skip an erc20 transfer
        IERC20(geist).safeTransferFrom(msg.sender, address(this), _amount);
        ILiGeistStrategy(strategy).createLock(_amount);
        ILiGeist(liGeist).mint(msg.sender, _amount);       
    }


    //deposit geist for liGeist
    function deposit(uint256 _amount) external {
        require(_amount > 0, "!>0");
        //lock immediately, transfer directly to strategy to skip an erc20 transfer
        _deposit(_amount);
    }

    function depositAll() external {
        uint256 geistBal = IERC20(geist).balanceOf(msg.sender);
        _deposit(geistBal);
    }

    function _deposit(uint256 _amount) internal {
        require(_amount > 0, "!>0");
        //lock immediately, transfer directly to strategy to skip an erc20 transfer
        IERC20(geist).safeTransferFrom(msg.sender, address(this), _amount);
        ILiGeistStrategy(strategy).increaseAmount(_amount);
        ILiGeist(liGeist).mint(msg.sender, _amount);
    }
}