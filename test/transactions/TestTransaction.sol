// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestTransaction is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function setUp() public virtual override {
        super.setUp();
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));
        _execute(_transactionName());
    }

    function _execute(string memory txName) internal virtual {
        Transaction memory transaction = _getTxData(txName);
        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.op);
    }

    function testAssertions() public virtual {
        assertTrue(true);
    }
}
