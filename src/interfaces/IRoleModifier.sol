// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import {IAvatar, Operation} from "./IAvatar.sol";
import {IModule} from "./IModule.sol";

enum ParameterType {
    Static,
    Dynamic,
    Dynamic32
}

enum Comparison {
    EqualTo,
    GreaterThan,
    LessThan,
    OneOf
}

enum Clearance {
    None,
    Target,
    Function
}

struct TargetAddress {
    Clearance clearance;
    ExecutionOptions options;
}

enum ExecutionOptions {
    None,
    Send,
    DelegateCall,
    Both
}

interface IRoleModifier is IAvatar, IModule {
    function setUp(bytes memory initParams) external;
    function setMultisend(address _multisend) external;
    function allowTarget(uint16 role, address targetAddress, ExecutionOptions options) external;
    function revokeTarget(uint16 role, address targetAddress) external;
    function scopeTarget(uint16 role, address targetAddress) external;
    function scopeAllowFunction(uint16 role, address targetAddress, bytes4 functionSig, ExecutionOptions options)
        external;
    function scopeRevokeFunction(uint16 role, address targetAddress, bytes4 functionSig) external;
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
    function unscopeParameter(uint16 role, address targetAddress, bytes4 functionSig, uint8 paramIndex) external;
    function assignRoles(address module, uint16[] calldata _roles, bool[] calldata memberOf) external;
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
