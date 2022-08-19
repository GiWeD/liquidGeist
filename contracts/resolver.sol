// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./interfaces/IStrategyResolver.sol";
import "./interfaces/IResolver.sol";


contract Resolver is IResolver {

    address public strategy;
    address public owner;

    uint256 public callPeriod;


    constructor(address _strategy) public {
        strategy = _strategy;
        callPeriod = 604800;
        owner = msg.sender;
    }


    function checker() external view override returns (bool canExec, bytes memory execPayload) {
        
        // claim every "callPeriod" (1week)
        canExec = block.timestamp >= IStrategyResolver(strategy).lastClaim() + callPeriod;

        execPayload = abi.encodeWithSelector(
            IStrategyResolver.claimRewards.selector
        );
    }





    function setStrategy(address _strategy) external {
        require(msg.sender == owner, 'not allowed');
        strategy = _strategy;
    }
    function setCallPeriod(uint256 _callPeriod) external {
        require(msg.sender == owner, 'not allowed');
        callPeriod = _callPeriod;
    }

    function setOwner(address _newOwner) external {
        require(msg.sender == owner, 'not allowed');
        owner = _newOwner;
    }


}