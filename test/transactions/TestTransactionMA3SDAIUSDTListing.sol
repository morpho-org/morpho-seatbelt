// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IMulticall} from "src/interfaces/IMulticall.sol";
import {Operation} from "src/libraries/Types.sol";
import "test/TestTransactionSetup.sol";

contract TestTransactionMA3SDAIUSDTListing is TestTransactionSetup {
    address internal constant S_DAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function setUp() public virtual override {
        super.setUp();
         _executeTestTransaction("TestTransactionMA3SDAIUSDTListing");
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 18127500;
    }

    function testAssertionsOfTransaction() public virtual {
        IMorphoAaveV3.Market memory market = morphoAaveV3.market(S_DAI);

        assertEq(market.underlying, S_DAI, "Wrong address");
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

        market = morphoAaveV3.market(USDT);
        assertEq(market.underlying, USDT, "Wrong address");
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
