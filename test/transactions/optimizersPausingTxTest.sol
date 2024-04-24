// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/DelayModifierTxTest.sol";

contract optimizersPausingTxTest is DelayModifierTxTest {
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant S_DAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant CB_ETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address[] internal pausedMC2Assets = [mcCOMP, mcWETH, mcUNI, mcUSDT];
    address[] internal pausedMA3Assets = [DAI, WBTC, S_DAI, USDT, CB_ETH];

    function _txName() internal pure override returns (string memory) {
        return "optimizersPausing";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 19_723_639;
    }

    function testOptimizersPausing() public {
        for (uint256 i; i < pausedMC2Assets.length; i++) {
            address asset = pausedMC2Assets[i];
            IMorphoCompound.MarketPauseStatus memory market = morphoCompound.marketPauseStatus(asset);

            assertTrue(market.isBorrowPaused, "mc2 isBorrowPaused");
            assertTrue(market.isSupplyPaused, "mc2 isSupplyPaused");
        }

        for (uint256 i; i < pausedMA3Assets.length; i++) {
            address asset = pausedMA3Assets[i];
            IMorphoAaveV3.Market memory market = morphoAaveV3.market(asset);

            assertTrue(market.pauseStatuses.isSupplyCollateralPaused, "ma3 isSupplyCollateralPaused");
        }
    }
}
