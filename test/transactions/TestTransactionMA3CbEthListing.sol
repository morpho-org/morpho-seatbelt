// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetup.sol";

contract TestTransactionMA3CbEthListing is TestTransactionSetup {
    address internal constant CB_ETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;

    function setUp() public virtual override {
        super.setUp();
        _executeTestTransaction("ma3CbEthListing");
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17_613_082;
    }

    function testAssertionsOfTransaction() public virtual {
        IMorphoAaveV3.Market memory market = morphoAaveV3.market(CB_ETH);

        assertEq(market.underlying, CB_ETH, "Wrong address");
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
