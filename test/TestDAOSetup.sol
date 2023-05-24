// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestDAOSetup is TestSetup {
	function testMorphoAdminAsOwnerOfProtocols() public {
		assertEq(Ownable(address(morphoCompound)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(morphoAaveV2)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(morphoAaveV3)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(proxyAdmin)).owner(), address(morphoAdmin));
	}
}
