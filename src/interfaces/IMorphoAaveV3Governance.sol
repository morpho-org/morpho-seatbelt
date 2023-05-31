// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IMorphoAaveV3Governance {
    struct Iterations {
        uint128 repay;
        uint128 withdraw;
    }

    struct Market {
        Indexes indexes;
        Deltas deltas; // 1024 bits
        address underlying; // 160 bits
        PauseStatuses pauseStatuses; // 80 bits
        bool isCollateral; // 8 bits
        address variableDebtToken; // 160 bits
        uint32 lastUpdateTimestamp; // 32 bits
        uint16 reserveFactor; // 16 bits
        uint16 p2pIndexCursor; // 16 bits
        address aToken; // 160 bits
        address stableDebtToken; // 160 bits
        uint256 idleSupply;
    }

    struct Indexes {
        MarketSideIndexes supply; // The `MarketSideIndexes` related to the supply side.
        MarketSideIndexes borrow; // The `MarketSideIndexes` related to the borrow side.
    }

    struct MarketSideIndexes {
        uint128 poolIndex; // The pool index (in ray).
        uint128 p2pIndex; // The peer-to-peer index (in ray).
    }

    struct Deltas {
        MarketSideDelta supply; // The `MarketSideDelta` related to the supply side.
        MarketSideDelta borrow; // The `MarketSideDelta` related to the borrow side.
    }

    struct MarketSideDelta {
        uint256 scaledDelta; // The delta amount in pool unit.
        uint256 scaledP2PTotal; // The total peer-to-peer amount in peer-to-peer unit.
    }

    struct PauseStatuses {
        bool isP2PDisabled;
        bool isSupplyPaused;
        bool isSupplyCollateralPaused;
        bool isBorrowPaused;
        bool isWithdrawPaused;
        bool isWithdrawCollateralPaused;
        bool isRepayPaused;
        bool isLiquidateCollateralPaused;
        bool isLiquidateBorrowPaused;
        bool isDeprecated;
    }

    function createMarket(address underlying, uint16 reserveFactor, uint16 p2pIndexCursor) external;
    function increaseP2PDeltas(address underlying, uint256 amount) external;
    function claimToTreasury(address[] calldata underlyings, uint256[] calldata amounts) external;

    function setPositionsManager(address positionsManager) external;
    function setRewardsManager(address rewardsManager) external;
    function setTreasuryVault(address treasuryVault) external;
    function setDefaultIterations(Iterations memory defaultIterations) external;
    function setP2PIndexCursor(address underlying, uint16 p2pIndexCursor) external;
    function setReserveFactor(address underlying, uint16 newReserveFactor) external;

    function setAssetIsCollateralOnPool(address underlying, bool isCollateral) external;
    function setAssetIsCollateral(address underlying, bool isCollateral) external;
    function setIsClaimRewardsPaused(bool isPaused) external;
    function setIsPaused(address underlying, bool isPaused) external;
    function setIsPausedForAllMarkets(bool isPaused) external;
    function setIsSupplyPaused(address underlying, bool isPaused) external;
    function setIsSupplyCollateralPaused(address underlying, bool isPaused) external;
    function setIsBorrowPaused(address underlying, bool isPaused) external;
    function setIsRepayPaused(address underlying, bool isPaused) external;
    function setIsWithdrawPaused(address underlying, bool isPaused) external;
    function setIsWithdrawCollateralPaused(address underlying, bool isPaused) external;
    function setIsLiquidateBorrowPaused(address underlying, bool isPaused) external;
    function setIsLiquidateCollateralPaused(address underlying, bool isPaused) external;
    function setIsP2PDisabled(address underlying, bool isP2PDisabled) external;
    function setIsDeprecated(address underlying, bool isDeprecated) external;

    function market(address underlying) external view returns (Market memory);
}
