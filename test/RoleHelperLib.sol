// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import {Vm} from "@forge-std/Vm.sol";
import {IRoles} from "src/interfaces/IRoles.sol";
import {TargetAddress, Clearance, ExecutionOptions, ParameterType, Comparison} from "src/libraries/Types.sol";

/// @dev The role modifier contract used by Morpho does not have an external getter for the role information.
///      This library provides getters to mirror what the getters would be if each mapping member in the roles struct
///      had an external getter when used with "using RoleHelperLib for IRoles".
library RoleHelperLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 internal constant ROLE_STORAGE_SLOT = 107;
    uint256 internal constant ROLES_MEMBERS_SLOT = 0;
    uint256 internal constant ROLES_TARGETS_SLOT = 1;
    uint256 internal constant ROLES_FUNCTIONS_SLOT = 2;
    uint256 internal constant ROLES_COMP_VALUES_SLOT = 3;
    uint256 internal constant ROLES_COMP_VALUES_ONE_OF_SLOT = 4;

    /* GETTERS */

    function members(IRoles roleModifier, uint16 role, address member) internal view returns (bool) {
        bytes32 storageSlot = keccak256(abi.encode(member, roleStorageHash(role, ROLES_MEMBERS_SLOT)));
        return abi.decode(abi.encode(vm.load((address(roleModifier)), storageSlot)), (bool));
    }

    function targets(IRoles roleModifier, uint16 role, address target) internal view returns (TargetAddress memory t) {
        bytes32 storageSlot = keccak256(abi.encode(target, roleStorageHash(role, ROLES_TARGETS_SLOT)));
        uint256 data = uint256(vm.load((address(roleModifier)), storageSlot));
        t.clearance = Clearance(uint8(data));
        t.options = ExecutionOptions(uint8(data >> 8));
    }

    function functions(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig)
        internal
        view
        returns (uint256 data)
    {
        bytes32 key = keyForFunctions(targetAddress, functionSig);
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, ROLES_FUNCTIONS_SLOT)));
        data = uint256(vm.load((address(roleModifier)), storageSlot));
    }

    function compValues(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig, uint256 index)
        internal
        view
        returns (bytes32 data)
    {
        bytes32 key = keyForCompValues(targetAddress, functionSig, index);
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, ROLES_COMP_VALUES_SLOT)));
        data = vm.load((address(roleModifier)), storageSlot);
    }

    function compValuesOneOf(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig, uint256 index)
        internal
        view
        returns (bytes32[] memory data)
    {
        bytes32 key = keyForCompValues(targetAddress, functionSig, index);
        bytes32 storageSlot = keccak256(abi.encode(key, roleStorageHash(role, ROLES_COMP_VALUES_ONE_OF_SLOT)));
        uint256 length = uint256(vm.load((address(roleModifier)), storageSlot));
        data = new bytes32[](length);

        for (uint256 i; i < length; i++) {
            data[i] = vm.load(address(roleModifier), keccak256(abi.encode(bytes32(uint256(storageSlot) + i))));
        }
    }

    function functionExecutionOptions(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig)
        internal
        view
        returns (ExecutionOptions options)
    {
        (options,,) = unpackFunction(functions(roleModifier, role, targetAddress, functionSig));
    }

    function functionIsWildcarded(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig)
        internal
        view
        returns (bool isWildcarded)
    {
        (, isWildcarded,) = unpackFunction(functions(roleModifier, role, targetAddress, functionSig));
    }

    function functionLength(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig)
        internal
        view
        returns (uint256 length)
    {
        (,, length) = unpackFunction(functions(roleModifier, role, targetAddress, functionSig));
    }

    function parameterIsScoped(
        IRoles roleModifier,
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint256 index
    ) internal view returns (bool isScoped) {
        (isScoped,,) = unpackParameter(functions(roleModifier, role, targetAddress, functionSig), index);
    }

    function parameterType(IRoles roleModifier, uint16 role, address targetAddress, bytes4 functionSig, uint256 index)
        internal
        view
        returns (ParameterType paramType)
    {
        (, paramType,) = unpackParameter(functions(roleModifier, role, targetAddress, functionSig), index);
    }

    function parameterComparison(
        IRoles roleModifier,
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint256 index
    ) internal view returns (Comparison paramComp) {
        (,, paramComp) = unpackParameter(functions(roleModifier, role, targetAddress, functionSig), index);
    }

    /* HELPERS */

    function roleStorageHash(uint16 role, uint256 offset) internal pure returns (bytes32) {
        return bytes32(uint256(keccak256(abi.encode(role, ROLE_STORAGE_SLOT))) + offset);
    }

    function keyForFunctions(address targetAddress, bytes4 functionSig) internal pure returns (bytes32) {
        return bytes32(abi.encodePacked(targetAddress, functionSig));
    }

    function keyForCompValues(address targetAddress, bytes4 functionSig, uint256 index)
        internal
        pure
        returns (bytes32)
    {
        return bytes32(abi.encodePacked(targetAddress, functionSig, uint8(index)));
    }

    function unpackFunction(uint256 scopeConfig)
        internal
        pure
        returns (ExecutionOptions options, bool isWildcarded, uint256 length)
    {
        uint256 isWildcardedMask = 1 << 253;

        options = ExecutionOptions(scopeConfig >> 254);
        isWildcarded = scopeConfig & isWildcardedMask != 0;
        length = (scopeConfig << 8) >> 248;
    }

    function unpackParameter(uint256 scopeConfig, uint256 index)
        internal
        pure
        returns (bool isScoped, ParameterType paramType, Comparison paramComp)
    {
        uint256 isScopedMask = 1 << (index + 96 + 96);
        uint256 paramTypeMask = 3 << (index * 2 + 96);
        uint256 paramCompMask = 3 << (index * 2);

        isScoped = (scopeConfig & isScopedMask) != 0;
        paramType = ParameterType((scopeConfig & paramTypeMask) >> (index * 2 + 96));
        paramComp = Comparison((scopeConfig & paramCompMask) >> (index * 2));
    }
}
