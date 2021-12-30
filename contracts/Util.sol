// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Evert Kors <dev@sherlock.xyz> (https://twitter.com/evert0x)
/******************************************************************************/

library Util {
  function getSelector(bytes memory _data) internal pure returns (bytes4 sig) {
    assembly {
      sig := mload(add(_data, 32))
    }
  }
}
