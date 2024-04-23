// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/MorphoDaoTxTest.sol";

contract assetPausingTxTest is MorphoDaoTxTest {
    address internal constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant S_DAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant CB_ETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;

    address[] internal pausedMC2Assets = [COMP, WETH, UNI, USDT];
    address[] internal pausedMA2Assets = [CRV];
    address[] internal pausedMA3Assets = [DAI, WBTC, S_DAI, USDT, CB_ETH];

    function _txName() internal pure override returns (string memory) {
        return "assetPausing";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 19_718_558;
    }

    function testAssetPausing() public {
        for (uint256 i; i < pausedMC2Assets.length; i++) {
            address asset = pausedMC2Assets[i];
            IMorphoCompound.MarketPauseStatus memory market = morphoCompound.marketPauseStatus(asset);

            assertTrue(market.isBorrowPaused, "mc2 isBorrowPaused");
            assertTrue(market.isSupplyPaused, "mc2 isSupplyPaused");
        }

        for (uint256 i; i < pausedMA2Assets.length; i++) {
            address asset = pausedMA2Assets[i];
            IMorphoAaveV2.MarketPauseStatus memory market = morphoAaveV2.marketPauseStatus(asset);

            assertTrue(market.isBorrowPaused, "ma2 isBorrowPaused");
            assertTrue(market.isSupplyPaused, "ma2 isSupplyPaused");
        }

        for (uint256 i; i < pausedMA3Assets.length; i++) {
            address asset = pausedMA3Assets[i];
            IMorphoAaveV3.Market memory market = morphoAaveV3.market(asset);

            assertTrue(market.pauseStatuses.isSupplyCollateralPaused, "ma3 isSupplyCollateralPaused");
        }
    }
}
