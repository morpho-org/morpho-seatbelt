// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IOwnerManager {
    function getThreshold() external view returns (uint256);
    function getOwners() external view returns (address[] memory);
}
