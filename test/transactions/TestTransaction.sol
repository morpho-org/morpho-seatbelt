// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestTransaction is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function setUp() public virtual override {
        super.setUp();
    }

    function testAssertionsOfTransaction() public virtual {
        assertTrue(true);
    }
}
