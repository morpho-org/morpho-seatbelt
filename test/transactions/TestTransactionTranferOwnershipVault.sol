// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetup.sol";

contract TestTransactionTransferOwnershipVault is TestTransactionSetup {
    address internal constant ma3WETH = 0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b;

    function setUp() public virtual override {
        super.setUp();
    }

    function testAssertionsOfTransaction() public virtual {
        assertEq(Ownable(address(ma3WETH)).owner(), address(morphoAdmin));
    }
}
