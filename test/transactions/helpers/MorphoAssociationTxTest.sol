// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TxTest.sol";

/// @notice The DAO can call all the governance functions including the ones that can be used by Morpho Operator.
/// It just needs to be executed through the Delay Modifier.
abstract contract MorphoAssociationTxTest is TxTest {
    constructor() {
        avatars.push(morphoAssociation);
    }

    function _execute(Tx memory transaction) internal virtual override {
        _execMorphoAssociationTx(transaction);
    }

    function _execMorphoAssociationTx(Tx memory transaction) internal {
        morphoAssociation.execTransactionFromModule(
            transaction.to, transaction.value, transaction.data, transaction.operation
        );
    }
}
