// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Evert Kors <dev@sherlock.xyz> (https://twitter.com/evert0x)
/******************************************************************************/

import './TimelockControllerDetailed.sol';

import 'hardhat/console.sol';

contract TimelockControllerDetailedDirect is TimelockControllerDetailed {
  uint256 public constant DIRECT_EXECUTION_DELAY = type(uint256).max;

  event DirectCallExecuted(address target, uint256 value, bytes data);

  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors
  ) TimelockControllerDetailed(minDelay, proposers, executors) {}

  function directExecute(
    address _target,
    uint256 _value,
    bytes calldata _data
  ) external onlyRole(PROPOSER_ROLE) {
    bytes4 selector = Util.getSelector(_data);

    require(
      detailedMinDelay[_target][selector] == DIRECT_EXECUTION_DELAY,
      'TimelockControllerDetailedDirect: invalid delay'
    );

    (bool success, ) = _target.call{ value: _value }(_data);
    require(success, 'TimelockControllerDetailedDirect: underlying transaction reverted');

    emit DirectCallExecuted(_target, _value, _data);
  }
}
