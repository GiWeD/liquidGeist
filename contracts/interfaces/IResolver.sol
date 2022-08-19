// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IResolver {
    function checker()
        external
        view
        returns (bool canExec, bytes memory execPayload);
}