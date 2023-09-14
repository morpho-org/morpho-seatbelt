// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import "./helpers/DelayModifierTxTest.sol";

contract ma3WethVaultAcceptOwnershipTxTest is DelayModifierTxTest {
    address internal constant MA3_WETH_VAULT = 0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b;

    function _txName() internal pure override returns (string memory) {
        return "ma3WethVaultAcceptOwnership";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17_514_636;
    }

    function testMa3WethVaultAcceptOwnership() public {
        assertEq(Ownable2Step(MA3_WETH_VAULT).owner(), address(morphoAdmin));
        assertEq(Ownable2Step(MA3_WETH_VAULT).pendingOwner(), address(0));
    }
}
