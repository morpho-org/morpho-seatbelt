// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import {IAvatar} from "src/interfaces/IAvatar.sol";
import {IOwnerManager} from "src/interfaces/IOwnerManager.sol";
import {Operation} from "src/libraries/Types.sol";

interface ISafe is IAvatar, IOwnerManager {
    function isModuleEnabled(address module) external view returns (bool);

    function getStorageAt(uint256 offset, uint256 length) external returns (bytes memory);
}
