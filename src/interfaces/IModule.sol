// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IModule {
    function avatar() external view returns (address);
	function target() external view returns (address);
}