# Timelock extensions

> Warning: untest & unaudited

The default OZ timelock can not be configured to function level. The goal of this codebase is to

- Have custom min delay timelock for specific functions
- Have custom proposer rights for specific functions

## TimelockControllerDetailed.sol

This contract allows users to configure a `minDelay` per contract-function combination. It still uses the global `minDelay` for every other function.

## TimelockControllerDetailedDirect.sol

This contract extends `TimelockControllerDetailed` by also providing a way to skip the timelocks 'schedule --> execute' flow and do an immediate execute.

## TimelockProposer.sol

In case you want a proposer to only propose specific functions
