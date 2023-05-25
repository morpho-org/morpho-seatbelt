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

	function testRoleModifier() public {
		assertEq(Ownable(address(roleModifier)).owner(), address(morphoAdmin));
		assertEq(IModule(address(roleModifier)).target(), address(morphoAdmin));
		assertEq(IModule(address(roleModifier)).avatar(), address(morphoAdmin));
		assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));
	}

	function testDelayModifier() public {
		assertEq(Ownable(address(delayModifier)).owner(), address(morphoAdmin));
		assertEq(IModule(address(delayModifier)).target(), address(morphoAdmin));
		assertEq(IModule(address(delayModifier)).avatar(), address(morphoAdmin));
		assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));
		assertEq(delayModifier.txCooldown(), 1 days);
		assertEq(delayModifier.txExpiration(), 0);
	}

	function testModules() public {
		// Role 1: operator
		assertEq(roleModifier.defaultRoles(address(operator)), 1);

		// morphoAdmin should accept tx from delay modifier
		assertTrue(morphoAdmin.isModuleEnabled(address(delayModifier)));

		// morphoAdmin should accept tx from role modifier
		assertTrue(morphoAdmin.isModuleEnabled(address(roleModifier)));

		// morphoDao should accept tx from delay modifier
		assertTrue(morphoAdmin.isModuleEnabled(address(roleModifier)));

		// morphoDao should not accept tx from role modifier
		assertFalse(morphoDao.isModuleEnabled(address(roleModifier)));

		// delay modifier should accept tx from morphoDao
		assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));

		// role modifier should accept tx from morphoDao
		assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));
	}
}
