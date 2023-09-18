// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.2;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IMorphoAaveV3SupplyVault is IERC4626 {
    function MORPHO() external view returns (address);

    function recipient() external view returns (address);

    function maxIterations() external view returns (uint96);

    function skim(address[] calldata tokens) external;

    function setMaxIterations(uint96 newMaxIterations) external;

    function setRecipient(address newRecipient) external;
}
