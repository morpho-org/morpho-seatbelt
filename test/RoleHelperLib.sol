// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.6;

import {Vm} from "@forge-std/Vm.sol";
import {IRoles} from "src/interfaces/IRoles.sol";
import {TargetAddress, Clearance, ExecutionOptions} from "src/libraries/Types.sol";

import {console2} from "@forge-std/console2.sol";

/// @dev The role modifier contract used by Morpho does not have an external getter for the role information.
///      This library provides getters to mirror what the getters would be if each mapping member in the roles struct
///      had an external getter when used with "using RoleHelperLib for IRoles".
library RoleHelperLib {
    uint256 internal constant ROLE_STORAGE_SLOT = 107;
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function members(IRoles roleModifier, uint16 role, address member) internal view returns (bool) {
        bytes32 storageSlot = keccak256(abi.encode(member, roleStorageHash(role, 0)));
        return abi.decode(abi.encode(vm.load((address(roleModifier)), storageSlot)), (bool));
    }

    function targets(IRoles roleModifier, uint16 role, address member) internal view returns (TargetAddress memory t) {
        bytes32 storageSlot = keccak256(abi.encode(member, roleStorageHash(role, 1)));
        uint256 data = uint256(vm.load((address(roleModifier)), storageSlot));
        t.clearance = Clearance(uint8(data));
        t.options = ExecutionOptions(uint8(data >> 8));
    }

    function functions(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig)
        internal
        view
        returns (uint256 data)
    {
        bytes32 key = bytes32(abi.encodePacked(targetAddress, functionSig));
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, 2)));
        data = uint256(vm.load((address(roleModifier)), storageSlot));
    }

    function compValues(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig, uint256 index)
        internal
        view
        returns (bytes32 data)
    {
        bytes32 key = bytes32(abi.encodePacked(targetAddress, functionSig, uint8(index)));
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, 3)));
        data = vm.load((address(roleModifier)), storageSlot);
    }

    function compValuesOneOf(
        IRoles roleModifier,
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint256 index,
        uint256 numElements
    ) internal view returns (bytes32[] memory data) {
        bytes32 key = bytes32(abi.encodePacked(targetAddress, functionSig, uint8(index)));
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, 4)));
        data = new bytes32[](numElements);
        for (uint256 i; i < numElements; i++) {
            data[i] = vm.load((address(roleModifier)), bytes32(uint256(storageSlot) + i));
        }
    }

    function roleStorageHash(uint16 role, uint256 offset) internal pure returns (bytes32) {
        return bytes32(uint256(keccak256(abi.encode(role, ROLE_STORAGE_SLOT))) + offset);
    }
}
