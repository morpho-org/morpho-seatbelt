// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import {IAvatar} from "src/interfaces/IAvatar.sol";
import {Operation, ExecutionOptions, Comparison, ParameterType} from "src/libraries/Types.sol";

interface IRoles is IAvatar {
    function setUp(bytes memory initParams) external;
    function setMultisend(address _multisend) external;
    function allowTarget(
        uint16 role,
        address targetAddress,
        ExecutionOptions options
    ) external;
    function revokeTarget(uint16 role, address targetAddress) external;
    function scopeTarget(uint16 role, address targetAddress)
        external;
    function scopeAllowFunction(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        ExecutionOptions options
    ) external;
    function scopeRevokeFunction(
        uint16 role,
        address targetAddress,
        bytes4 functionSig
    ) external;
    function scopeFunction(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        bool[] calldata isParamScoped,
        ParameterType[] calldata paramType,
        Comparison[] calldata paramComp,
        bytes[] memory compValue,
        ExecutionOptions options
    ) external;
    function scopeFunctionExecutionOptions(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        ExecutionOptions options
    ) external;
    function scopeParameter(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint256 paramIndex,
        ParameterType paramType,
        Comparison paramComp,
        bytes calldata compValue
    ) external;
    function scopeParameterAsOneOf(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint256 paramIndex,
        ParameterType paramType,
        bytes[] calldata compValues
    ) external;
    function unscopeParameter(
        uint16 role,
        address targetAddress,
        bytes4 functionSig,
        uint8 paramIndex
    ) external;
    function assignRoles(
        address module,
        uint16[] calldata _roles,
        bool[] calldata memberOf
    ) external;
    function setDefaultRole(address module, uint16 role) external;
    function execTransactionWithRole(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint16 role,
        bool shouldRevert
    ) external;
    function execTransactionWithRoleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint16 role,
        bool shouldRevert
    ) external;

    function multisend() external view returns (address);
    function defaultRoles(address) external view returns (uint16);
}