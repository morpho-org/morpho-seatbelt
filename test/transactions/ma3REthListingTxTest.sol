// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/DelayModifierTxTest.sol";

contract ma3REthListingTxTest is DelayModifierTxTest {
    address internal constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;

    function _txName() internal pure override returns (string memory) {
        return "ma3REthListing";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17_404_894;
    }

    function testMa3RETHListing() public {
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
