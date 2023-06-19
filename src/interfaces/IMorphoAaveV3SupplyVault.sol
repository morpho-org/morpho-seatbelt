// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

import {IERC4626Upgradeable} from "@openzeppelin-contracts-upgradeable/contracts/interfaces/IERC4626Upgradeable.sol";

interface IMorphoAaveV3SupplyVault is IERC4626Upgradeable {
    function MORPHO() external view returns (address);

    function recipient() external view returns (address);

    function maxIterations() external view returns (uint96);

    function skim(address[] calldata tokens) external;

    function setMaxIterations(uint96 newMaxIterations) external;

    function setRecipient(address newRecipient) external;
}
