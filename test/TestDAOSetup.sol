// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/interfaces/IModule.sol";
import "test/TestSetup.sol";

contract TestDAOSetup is TestSetup {
	function testMorphoAdminAsOwnerOfProtocols() public {
		assertEq(Ownable(address(morphoCompound)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(morphoAaveV2)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(morphoAaveV3)).owner(), address(morphoAdmin));
		assertEq(Ownable(address(proxyAdmin)).owner(), address(morphoAdmin));
	}

	function testMorphoDaoRole() public {
		assertEq(Ownable(address(roleModifier)).owner(), address(morphoAdmin));
		assertEq(IModule(address(roleModifier)).target(), address(morphoAdmin));
		assertEq(IModule(address(roleModifier)).avatar(), address(morphoAdmin));
		assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));

	}

	function testDelay() public {
		assertEq(Ownable(address(delayModifier)).owner(), address(morphoAdmin));
		assertEq(IModule(address(delayModifier)).target(), address(morphoAdmin));
		assertEq(IModule(address(delayModifier)).avatar(), address(morphoAdmin));
		assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));
		assertEq(delayModifier.txCooldown(), 1 days);
		assertEq(delayModifier.txExpiration(), 0);
	}
}
