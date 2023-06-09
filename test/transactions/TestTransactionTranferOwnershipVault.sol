// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetup.sol";

import {Ownable2Step} from "@openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract TestTransactionTransferOwnershipVault is TestTransactionSetup {
    address internal constant ma3WETH = 0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b;

    function setUp() public virtual override {
        super.setUp();
        _executeTestTransaction("testTransferOwnershipVaultMA3WEth");
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17514636;
    }

    function testAssertionsOfTransaction() public virtual {
        assertEq(Ownable2Step(address(ma3WETH)).owner(), address(morphoAdmin));
        assertEq(Ownable2Step(address(ma3WETH)).pendingOwner(), address(0));
    }
}
