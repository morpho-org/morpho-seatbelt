// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IModule {
    function avatar() external view returns (address);
    function target() external view returns (address);
}
