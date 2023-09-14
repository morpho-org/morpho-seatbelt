// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/DelayModifierTxTest.sol";

contract ma3SDaiUsdtListingTxTest is DelayModifierTxTest {
    address internal constant S_DAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function _txName() internal pure override returns (string memory) {
        return "ma3SDaiUsdtListing";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 18_127_991;
    }

    function testSDaiUsdtListing() public {
        IMorphoAaveV3.Market memory market = morphoAaveV3.market(S_DAI);

        assertEq(market.underlying, S_DAI, "aSDai.underlying");
        assertTrue(market.pauseStatuses.isBorrowPaused, "aSDai.isBorrowPaused");
        assertTrue(market.pauseStatuses.isSupplyPaused, "aSDai.isSupplyPaused");
        assertTrue(market.pauseStatuses.isRepayPaused, "aSDai.isRepayPaused");

        // Should be True, but was paused later via the operator.
        assertFalse(market.pauseStatuses.isWithdrawPaused, "aSDai.isWithdrawPaused");

        assertTrue(market.pauseStatuses.isLiquidateBorrowPaused, "aSDai.isLiquidateBorrowPaused");
        assertTrue(market.pauseStatuses.isP2PDisabled, "aSDai.isP2PDisabled");
        assertFalse(market.pauseStatuses.isSupplyCollateralPaused, "aSDai.isSupplyCollateralPaused");
        assertFalse(market.pauseStatuses.isWithdrawCollateralPaused, "aSDai.isWithdrawCollateralPaused");
        assertFalse(market.pauseStatuses.isDeprecated, "aSDai.isDeprecated");
        assertFalse(market.pauseStatuses.isLiquidateCollateralPaused, "aSDai.isLiquidateCollateralPaused");
        assertEq(market.reserveFactor, 0, "aSDai.reserveFactor");
        assertEq(market.p2pIndexCursor, 0, "aSDai.p2pIndexCursor");
        assertTrue(market.isCollateral, "aSDai.isCollateral");

        market = morphoAaveV3.market(USDT);

        assertEq(market.underlying, USDT, "aUsdt.underlying");
        assertTrue(market.pauseStatuses.isBorrowPaused, "aUsdt.isBorrowPaused");
        assertTrue(market.pauseStatuses.isSupplyPaused, "aUsdt.isSupplyPaused");
        assertTrue(market.pauseStatuses.isRepayPaused, "aUsdt.isRepayPaused");
        assertTrue(market.pauseStatuses.isWithdrawPaused, "aUsdt.isWithdrawPaused");
        assertTrue(market.pauseStatuses.isLiquidateBorrowPaused, "aUsdt.isLiquidateBorrowPaused");
        assertTrue(market.pauseStatuses.isP2PDisabled, "aUsdt.isP2PDisabled");
        assertFalse(market.pauseStatuses.isSupplyCollateralPaused, "aUsdt.isSupplyCollateralPaused");
        assertFalse(market.pauseStatuses.isWithdrawCollateralPaused, "aUsdt.isWithdrawCollateralPaused");
        assertFalse(market.pauseStatuses.isDeprecated, "aUsdt.isDeprecated");
        assertFalse(market.pauseStatuses.isLiquidateCollateralPaused, "aUsdt.isLiquidateCollateralPaused");
        assertEq(market.reserveFactor, 0, "aUsdt.reserveFactor");
        assertEq(market.p2pIndexCursor, 0, "aUsdt.p2pIndexCursor");
        assertTrue(market.isCollateral, "aUsdt.isCollateral");
    }
}
