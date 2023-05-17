// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import {Operation} from "src/libraries/Types.sol";

interface IAvatar {
    event EnabledModule(address module);
    event DisabledModule(address module);
    event ExecutionFromModuleSuccess(address indexed module);
    event ExecutionFromModuleFailure(address indexed module);

    function enableModule(address module) external;
    function disableModule(address prevModule, address module) external;
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Operation operation)
        external
        returns (bool success);
    function execTransactionFromModuleReturnData(address to, uint256 value, bytes memory data, Operation operation)
        external
        returns (bool success, bytes memory returnData);
    function isModuleEnabled(address module) external view returns (bool);
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);
}
