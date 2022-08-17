// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface ILockedGeist {
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }

    function stake(uint256 amount, bool lock) external;
    function getReward() external;
    function withdrawExpiredLocks() external;

    function lockedBalances(address user) view external returns (uint256 total, uint256 unlockable, uint256 locked, LockedBalance[] memory lockData);



}