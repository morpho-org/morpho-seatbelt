// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MorphoDaoTxTest.sol";

/// @notice The DAO can call all the governance functions including the ones that can be used by Morpho Operator.
/// It just needs to be executed through the Delay Modifier.
abstract contract DelayModifierTxTest is MorphoDaoTxTest {
    constructor() {
        avatars.push(operator);
    }

    function _execute(Tx memory transaction) internal virtual override {
        super._execute(
            Tx({
                to: address(delayModifier),
                value: 0,
                data: abi.encodeCall(
                    IAvatar.execTransactionFromModule,
                    (transaction.to, transaction.value, transaction.data, transaction.operation)
                    ),
                operation: Operation.Call
            })
        );

        vm.warp(block.timestamp + delayModifier.txCooldown());

        _execDelayModifierTx(transaction);
    }

    function _execDelayModifierTx(Tx memory transaction) internal {
        bytes32 txHash =
            delayModifier.getTransactionHash(transaction.to, transaction.value, transaction.data, transaction.operation);
        uint256 txNonce = delayModifier.txNonce();

        uint256 currTxNonce = txNonce;
        while (delayModifier.txHash(txNonce) != txHash) {
            ++txNonce;
        }

        if (currTxNonce != txNonce) {
            vm.prank(address(morphoAdmin));
            delayModifier.setTxNonce(txNonce);
        }

        delayModifier.executeNextTx(transaction.to, transaction.value, transaction.data, transaction.operation);
    }
}
