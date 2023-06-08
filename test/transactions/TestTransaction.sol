// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetUp.sol";

contract TestTransaction is TestSetUp {
    /// @dev Operation is bool because foundry does not fuzz the enum correctly.
    function testUnwrapTx(address to, uint256 value, bool operation) public virtual {
        Transaction memory transaction = Transaction({
            to: to,
            value: value,
            data: hex"1234",
            operation: operation ? Operation.DelegateCall : Operation.Call
        });

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
