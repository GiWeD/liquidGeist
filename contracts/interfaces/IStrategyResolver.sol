
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


interface IStrategyResolver{

    function claimRewards() external;
    function lastClaim() external view returns(uint256);
    
}