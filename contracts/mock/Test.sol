// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Evert Kors <dev@sherlock.xyz> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/access/Ownable.sol';

contract Test is Ownable {
  function test1() external onlyOwner {}

  function test2(uint256 x) external onlyOwner {}

  function test3(uint256 x, address y) external onlyOwner {}

  function testOpen() external {}
}
