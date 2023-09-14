// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import {IAvatar} from "./IAvatar.sol";
import {IOwnerManager} from "./IOwnerManager.sol";

interface ISafe is IAvatar, IOwnerManager {
    function isModuleEnabled(address module) external view returns (bool);

    function getStorageAt(uint256 offset, uint256 length) external returns (bytes memory);
}
