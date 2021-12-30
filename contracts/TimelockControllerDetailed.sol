// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Evert Kors <dev@sherlock.xyz> (https://twitter.com/evert0x)
/******************************************************************************/

import '@openzeppelin/contracts/governance/TimelockController.sol';

import 'hardhat/console.sol';

contract TimelockControllerDetailed is TimelockController {
  /**
   * @dev Emitted when the minimum delay of a certain function on a contract for future operations is modified.
   */

  bytes4 constant UPDATE_DETAILED_MIN_DELAY =
    TimelockControllerDetailed.updateDetailedMinDelay.selector;

  event DetailedMinDelayChange(
    address indexed target,
    bytes4 indexed functionSignature,
    uint256 oldDuration,
    uint256 newDuration
  );

  mapping(address => mapping(bytes4 => uint256)) public detailedMinDelay;

  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors
  ) TimelockController(minDelay, proposers, executors) {}

  function getSelector(bytes memory _data) internal pure returns (bytes4 sig) {
    assembly {
      sig := mload(add(_data, 32))
    }
  }

  function _validateMinDelay(
    address _target,
    bytes calldata _data,
    uint256 _delay
  ) internal view {
    // Get function selector of call that is about to be scheduled
    bytes4 selector = getSelector(_data);

    if (_target == address(this) && selector == UPDATE_DETAILED_MIN_DELAY) {
      // A detailed delay of a function is going to be updated
      // We need to extract the function that is going to be updated

      // Decode selector from data
      // Abi encoding pads all types to 32 bytes
      // Extract first argument (after function selector), which is the function that is going to be updated
      // 0-4 = UPDATE_DETAILED_MIN_DELAY
      // 4-36 = bytes4 _func
      // 36-.. = other arguments
      selector = abi.decode(_data[4:36], (bytes4));
    }

    // Check if custom delay is set for the contract + function
    uint256 minDelay = detailedMinDelay[_target][selector];
    // In case custom delay, verify if passen in delay is bigger or equal
    if (minDelay != 0) require(_delay >= minDelay, 'TimelockControllerDetailed: delay too short');

    // Either way, the global minDelay is always checked again in the underlying call
  }

  function scheduleBatch(
    address[] calldata _targets,
    uint256[] calldata _values,
    bytes[] calldata _datas,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) public virtual override {
    require(_targets.length == _datas.length, 'TimelockControllerDetailed: length mismatch');

    for (uint256 i = 0; i < _targets.length; ++i) {
      _validateMinDelay(_targets[i], _datas[i], _delay);
    }
    super.scheduleBatch(_targets, _values, _datas, _predecessor, _salt, _delay);
  }

  function schedule(
    address _target,
    uint256 _value,
    bytes calldata _data,
    bytes32 _predecessor,
    bytes32 _salt,
    uint256 _delay
  ) public virtual override {
    _validateMinDelay(_target, _data, _delay);
    super.schedule(_target, _value, _data, _predecessor, _salt, _delay);
  }

  function updateDetailedMinDelay(
    bytes4 _func,
    address _target,
    uint256 _minDelay
  ) external {
    require(msg.sender == address(this), 'TimelockControllerDetailed: caller must be timelock');
    require(
      _minDelay >= getMinDelay(),
      'TimelockControllerDetailed: detailed delay is smaller than global delay'
    );

    uint256 oldMinDelay = detailedMinDelay[_target][_func];
    detailedMinDelay[_target][_func] = _minDelay;

    emit DetailedMinDelayChange(_target, _func, oldMinDelay, _minDelay);
  }
}
