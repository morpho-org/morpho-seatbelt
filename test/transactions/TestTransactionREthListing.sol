// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetup.sol";

contract TestTransactionREthListing is TestTransactionSetup {
    address internal constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;

    function setUp() public virtual override {
        super.setUp();
        _executeTestTransaction("testREth");
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17404894;
    }

    function testAssertionsOfTransaction() public virtual {
        IMorphoAaveV3.Market memory market = morphoAaveV3.market(RETH);

        assertEq(market.underlying, RETH, "Wrong address");
        assertTrue(market.pauseStatuses.isBorrowPaused);
        assertTrue(market.pauseStatuses.isSupplyPaused);
        assertTrue(market.pauseStatuses.isRepayPaused);
        assertTrue(market.pauseStatuses.isWithdrawPaused);
        assertTrue(market.pauseStatuses.isLiquidateBorrowPaused);
        assertTrue(market.pauseStatuses.isP2PDisabled);
        assertFalse(market.pauseStatuses.isSupplyCollateralPaused);
        assertFalse(market.pauseStatuses.isWithdrawCollateralPaused);
        assertFalse(market.pauseStatuses.isDeprecated);
        assertFalse(market.pauseStatuses.isLiquidateCollateralPaused);
        assertEq(market.reserveFactor, 0, "Wrong reserve Factor");
        assertEq(market.p2pIndexCursor, 0, "Wrong p2pIndexCursor");
        assertTrue(market.isCollateral, "Asset not Collateral");
    }
}
