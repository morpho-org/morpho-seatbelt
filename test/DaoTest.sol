// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IModule} from "src/interfaces/IModule.sol";

import "./helpers/ForkTest.sol";

contract DaoTest is ForkTest {
    uint256 internal constant GUARD_STORAGE_SLOT = uint256(keccak256("guard_manager.guard.address"));

    function testMorphoAdminAsOwnerOfProtocols() public {
        assertEq(Ownable(address(morphoCompound)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(morphoAaveV2)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(morphoAaveV3)).owner(), address(morphoAdmin));
        assertEq(proxyAdmin.owner(), address(morphoAdmin));
    }

    function testMorphoAdminAsOwnerOfVaults() public {
        assertEq(Ownable(address(maWBTC)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(maUSDC)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(maUSDT)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(maCRV)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(maWETH)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(maDAI)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcWTBC)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcUSDT)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcUSDC)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcUNI)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcCOMP)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcWETH)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(mcDAI)).owner(), address(morphoAdmin));
    }

    function testRoleModifier() public {
        assertEq(Ownable(address(roleModifier)).owner(), address(morphoAdmin));
        assertEq(roleModifier.target(), address(morphoAdmin));
        assertEq(roleModifier.avatar(), address(morphoAdmin));
        assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));
    }

    function testDelayModifier() public {
        assertEq(Ownable(address(delayModifier)).owner(), address(morphoAdmin));
        assertEq(delayModifier.target(), address(morphoAdmin));
        assertEq(delayModifier.avatar(), address(morphoAdmin));
        assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));
        assertEq(delayModifier.txCooldown(), 1 days);
        assertEq(delayModifier.txExpiration(), 0);
    }

    function testModules() public {
        // Role 1: operator
        assertEq(roleModifier.defaultRoles(address(operator)), 1);

        // morphoAdmin should accept tx from delay modifier.
        assertTrue(morphoAdmin.isModuleEnabled(address(delayModifier)));

        // morphoAdmin should accept tx from role modifier.
        assertTrue(morphoAdmin.isModuleEnabled(address(roleModifier)));

        // morphoDao should not accept tx from role modifier.
        assertFalse(morphoDao.isModuleEnabled(address(roleModifier)));

        // delay modifier should accept tx from morphoDao.
        assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));

        // role modifier should accept tx from morphoDao.
        assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));

        // delay modifier should not accept tx from operator.
        assertFalse(delayModifier.isModuleEnabled(address(operator)));

        // role modifier should accept tx from operator.
        assertTrue(roleModifier.isModuleEnabled(address(operator)));

        // operator should not accept tx from role modifier.
        assertFalse(operator.isModuleEnabled(address(roleModifier)));
    }

    /// @dev The guard prevents morphoAdmin's signer to submit any tx on the multisig.
    function testScopeGuard() public {
        assertEq(Ownable(address(scopeGuard)).owner(), address(morphoAdmin));
        assertEq(abi.decode(morphoAdmin.getStorageAt(GUARD_STORAGE_SLOT, 1), (address)), scopeGuard);
    }

    function testThresholdSafe() public {
        assertEq(operator.getThreshold(), 3, "Wrong Threshold for Operator");
        assertEq(morphoDao.getThreshold(), 5, "Wrong Threshold for DAO");
    }

    function testOperatorOwnersIsDaoOwners() public {
        address[] memory operatorOwners = operator.getOwners();

        assertEq(operatorOwners.length, owners.length, "operatorOwners.length");

        bool success;
        for (uint256 i; i < operatorOwners.length; i++) {
            success = false;
            for (uint256 j; j < owners.length; j++) {
                if (operatorOwners[i] == owners[j]) {
                    success = true;
                    break;
                }
            }
            assertTrue(success, "Owner not expected");
        }
    }
}
