// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestSetUp.sol";

/// @notice The DAO can call all the governance functions including the ones that can be used by Morpho Operator.
/// @notice It just needs to be executed through the Delay Modifier.
contract TestTransactionSetUp is TestSetUp {
    function setUp() public virtual override {
        super.setUp();
        _executeTestTransaction(_txName());
    }

    function _addModule(IAvatar avatar, address module) internal {
        vm.prank(address(avatar));
        avatar.enableModule(module);
    }

    function _executeTestTransaction(string memory filename) internal {
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));

        Transaction memory transaction = _getTxData(filename);

        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.operation);

        vm.warp(block.timestamp + delayModifier.txCooldown());
        uint256 txNonce = delayModifier.txNonce();
        uint256 currentTxNonce = txNonce;
        Transaction memory unwrappedTransaction = _unwrapTxData(transaction.data);
        bytes32 txHash = delayModifier.getTransactionHash(
            unwrappedTransaction.to,
            unwrappedTransaction.value,
            unwrappedTransaction.data,
            unwrappedTransaction.operation
        );

        while (delayModifier.txHash(txNonce) != txHash) {
            ++txNonce;
        }

        if (currentTxNonce != txNonce) {
            vm.prank(address(morphoAdmin));
            delayModifier.setTxNonce(txNonce);
        }

        delayModifier.executeNextTx(
            unwrappedTransaction.to,
            unwrappedTransaction.value,
            unwrappedTransaction.data,
            unwrappedTransaction.operation
        );
    }
}
