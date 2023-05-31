// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestTransaction is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    function setUp() public virtual override {
        super.setUp();
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));
        Transaction memory transaction = Transaction({
            to: address(morphoAaveV3),
            value: 0,
            data: abi.encodeCall(IMorphoAaveV3Governance.setIsSupplyCollateralPaused, (WBTC, true)),
            op: Operation.Call
        });
        morphoDao.execTransactionFromModule(address(delayModifier), 0, _wrapTxData(transaction), Operation.Call);
        vm.warp(block.timestamp + 100_000);
        delayModifier.executeNextTx(transaction.to, transaction.value, transaction.data, transaction.op);
    }

    function testAssertions() public virtual {
        assertTrue(morphoAaveV3.market(WBTC).pauseStatuses.isSupplyCollateralPaused);
    }
}
