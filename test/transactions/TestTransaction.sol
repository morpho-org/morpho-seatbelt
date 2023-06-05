// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestTransaction is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function setUp() public virtual override {
        super.setUp();
    }

    function testUnwrapTx1() public virtual {
        Transaction memory transaction =
            Transaction({to: address(0), value: 1000, data: hex"1234", operation: Operation.Call});
        _testUnwrapTx(transaction);
    }

    function testUnwrapTx2() public virtual {
        Transaction memory transaction =
            Transaction({to: address(1), value: 1000, data: hex"1234", operation: Operation.Call});
        _testUnwrapTx(transaction);
    }

    function _testUnwrapTx(Transaction memory transaction) public {
        bytes memory wrappedTx = _wrapTxData(transaction);

        bytes4 selector = _getSelector(wrappedTx);
        assertEq(selector, IAvatar.execTransactionFromModule.selector, "Selector mismatch");

        Transaction memory transactionToCheck = _unwrapTxData(wrappedTx);
        assertEq(transaction.to, transactionToCheck.to, "To mismatch");
        assertEq(transaction.value, transactionToCheck.value, "Value mismatch");
        assertEq(transaction.data, transactionToCheck.data, "Data mismatch");
        assertEq(
            transaction.operation == Operation.DelegateCall,
            transactionToCheck.operation == Operation.DelegateCall,
            "Operation mismatch"
        );
    }
}
