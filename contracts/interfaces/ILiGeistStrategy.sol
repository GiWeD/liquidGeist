// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;




interface ILiGeistStrategy {
    
    function balanceOfInSpirit() external view returns (uint256);
    function deposit(address, address) external;
    function withdrawableBalance() external;
    function withdrawAndRelock() external;
    function createLock(uint256) external;
    function increaseAmount(uint256) external;
    function claimRewards(address) external;
}