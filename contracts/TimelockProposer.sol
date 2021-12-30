// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Evert Kors <dev@sherlock.xyz> (https://twitter.com/evert0x)
/******************************************************************************/

import './Util.sol';
import '@openzeppelin/contracts/governance/TimelockController.sol';

import 'hardhat/console.sol';

interface ITimelockController {
  function schedule(
    address _target,
    uint256 _value,
    bytes calldata _data,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) external;

  function scheduleBatch(
    address[] calldata _targets,
    uint256[] calldata _values,
    bytes[] calldata _datas,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) external;
}

contract TimelockProposer {
  event ProposalCallAllowed(address target, bytes4 functionSignature);

  address public immutable proposer;
  ITimelockController public immutable timelock;

  mapping(address => mapping(bytes4 => bool)) public allowedProposal;

  constructor(
    address _proposer,
    ITimelockController _timelock,
    address[] memory allowContract,
    bytes4[] memory allowFunction
  ) {
    require(allowContract.length == allowFunction.length, 'TimelockProposer: not equal');

    proposer = _proposer;
    timelock = _timelock;

    for (uint256 i; i < allowContract.length; i++) {
      allowedProposal[allowContract[i]][allowFunction[i]] = true;

      emit ProposalCallAllowed(allowContract[i], allowFunction[i]);
    }
  }

  function _validateAllow(address _target, bytes calldata _data) internal view {
    bytes4 selector = Util.getSelector(_data);
    require(allowedProposal[_target][selector], 'TimelockProposer: function proposal not allowed');
  }

  function schedule(
    address _target,
    uint256 _value,
    bytes calldata _data,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) external {
    require(msg.sender == proposer, 'TimelockProposer: invalid sender');
    _validateAllow(_target, _data);
    timelock.schedule(_target, _value, _data, _predecessor, _salt, _delay);
  }

  function scheduleBatch(
    address[] calldata _targets,
    uint256[] calldata _values,
    bytes[] calldata _datas,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) external {
    require(msg.sender == proposer, 'TimelockProposer: invalid sender');
    require(_targets.length == _datas.length, 'TimelockProposer: not equal');

    for (uint256 i; i < _targets.length; i++) {
      _validateAllow(_targets[i], _datas[i]);
    }
    timelock.scheduleBatch(_targets, _values, _datas, _predecessor, _salt, _delay);
  }
}
