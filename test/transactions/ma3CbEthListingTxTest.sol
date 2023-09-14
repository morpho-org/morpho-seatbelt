// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/DelayModifierTxTest.sol";

contract ma3CbEthListingTxTest is DelayModifierTxTest {
    address internal constant CB_ETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;

    function _txName() internal pure override returns (string memory) {
        return "ma3CbEthListing";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17_613_082;
    }

    function testMa3CbEthListing() public {
        IMorphoAaveV3.Market memory market = morphoAaveV3.market(CB_ETH);

        assertEq(market.underlying, CB_ETH, "aCbEth.underlying");
        assertTrue(market.pauseStatuses.isBorrowPaused, "aCbEth.isBorrowPaused");
        assertTrue(market.pauseStatuses.isSupplyPaused, "aCbEth.isSupplyPaused");
        assertTrue(market.pauseStatuses.isRepayPaused, "aCbEth.isRepayPaused");
        assertTrue(market.pauseStatuses.isWithdrawPaused, "aCbEth.isWithdrawPaused");
        assertTrue(market.pauseStatuses.isLiquidateBorrowPaused, "aCbEth.isLiquidateBorrowPaused");
        assertTrue(market.pauseStatuses.isP2PDisabled, "aCbEth.isP2PDisabled");
        assertFalse(market.pauseStatuses.isSupplyCollateralPaused, "aCbEth.isSupplyCollateralPaused");
        assertFalse(market.pauseStatuses.isWithdrawCollateralPaused, "aCbEth.isWithdrawCollateralPaused");
        assertFalse(market.pauseStatuses.isDeprecated, "aCbEth.isDeprecated");
        assertFalse(market.pauseStatuses.isLiquidateCollateralPaused, "aCbEth.isLiquidateCollateralPaused");
        assertEq(market.reserveFactor, 0, "aCbEth.reserveFactor");
        assertEq(market.p2pIndexCursor, 0, "aCbEth.p2pIndexCursor");
        assertTrue(market.isCollateral, "aCbEth.isCollateral");
    }
}
