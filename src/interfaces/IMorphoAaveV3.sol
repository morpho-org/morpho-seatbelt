// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

struct Iterations {
    uint128 repay;
    uint128 withdraw;
}

interface IMorphoAaveV3Governance {
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
}

interface IMorphoAaveV3Getters {
    /// @notice Enumeration of the different position types in the protocol.
    enum Position {
        POOL_SUPPLIER,
        P2P_SUPPLIER,
        POOL_BORROWER,
        P2P_BORROWER
    }

    /* NESTED STRUCTS */

    /// @notice Contains the market side delta data.
    struct MarketSideDelta {
        uint256 scaledDelta; // The delta amount in pool unit.
        uint256 scaledP2PTotal; // The total peer-to-peer amount in peer-to-peer unit.
    }

    /// @notice Contains the delta data for both `supply` and `borrow`.
    struct Deltas {
        MarketSideDelta supply; // The `MarketSideDelta` related to the supply side.
        MarketSideDelta borrow; // The `MarketSideDelta` related to the borrow side.
    }

    /// @notice Contains the market side indexes.
    struct MarketSideIndexes {
        uint128 poolIndex; // The pool index (in ray).
        uint128 p2pIndex; // The peer-to-peer index (in ray).
    }

    /// @notice Contains the indexes for both `supply` and `borrow`.
    struct Indexes {
        MarketSideIndexes supply; // The `MarketSideIndexes` related to the supply side.
        MarketSideIndexes borrow; // The `MarketSideIndexes` related to the borrow side.
    }

    /// @notice Contains the different pauses statuses possible in Morpho.
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

    /* STORAGE STRUCTS */

    /// @notice Contains the market data that is stored in storage.
    /// @dev This market struct is able to be passed into memory.
    struct Market {
        // SLOT 0-1
        Indexes indexes;
        // SLOT 2-5
        Deltas deltas; // 1024 bits
        // SLOT 6
        address underlying; // 160 bits
        PauseStatuses pauseStatuses; // 80 bits
        bool isCollateral; // 8 bits
        // SLOT 7
        address variableDebtToken; // 160 bits
        uint32 lastUpdateTimestamp; // 32 bits
        uint16 reserveFactor; // 16 bits
        uint16 p2pIndexCursor; // 16 bits
        // SLOT 8
        address aToken; // 160 bits
        // SLOT 9
        address stableDebtToken; // 160 bits
        // SLOT 10
        uint256 idleSupply; // 256 bits
    }

    /* STACK AND RETURN STRUCTS */

    /// @notice Contains the data related to the liquidity of a user.
    struct LiquidityData {
        uint256 borrowable; // The maximum debt value allowed to borrow (in base currency).
        uint256 maxDebt; // The maximum debt value allowed before being liquidatable (in base currency).
        uint256 debt; // The debt value (in base currency).
    }

    /// @notice Contains the indexes as uint256 instead of uint128.
    struct Indexes256 {
        MarketSideIndexes256 supply; // The `MarketSideIndexes` related to the supply as uint256.
        MarketSideIndexes256 borrow; // The `MarketSideIndexes` related to the borrow as uint256.
    }

    /// @notice Contains the market side indexes as uint256 instead of uint128.
    struct MarketSideIndexes256 {
        uint256 poolIndex; // The pool index (in ray).
        uint256 p2pIndex; // The peer-to-peer index (in ray).
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function pool() external view returns (address);
    function addressesProvider() external view returns (address);
    function eModeCategoryId() external view returns (uint256);

    function market(address underlying) external view returns (Market memory);
    function marketsCreated() external view returns (address[] memory);

    function scaledCollateralBalance(address underlying, address user) external view returns (uint256);
    function scaledP2PBorrowBalance(address underlying, address user) external view returns (uint256);
    function scaledP2PSupplyBalance(address underlying, address user) external view returns (uint256);
    function scaledPoolBorrowBalance(address underlying, address user) external view returns (uint256);
    function scaledPoolSupplyBalance(address underlying, address user) external view returns (uint256);

    function supplyBalance(address underlying, address user) external view returns (uint256);
    function borrowBalance(address underlying, address user) external view returns (uint256);
    function collateralBalance(address underlying, address user) external view returns (uint256);

    function userCollaterals(address user) external view returns (address[] memory);
    function userBorrows(address user) external view returns (address[] memory);

    function isManagedBy(address delegator, address manager) external view returns (bool);
    function userNonce(address user) external view returns (uint256);

    function defaultIterations() external view returns (Iterations memory);
    function positionsManager() external view returns (address);
    function rewardsManager() external view returns (address);
    function treasuryVault() external view returns (address);

    function isClaimRewardsPaused() external view returns (bool);

    function updatedIndexes(address underlying) external view returns (Indexes256 memory);
    function liquidityData(address user) external view returns (LiquidityData memory);
    function getNext(address underlying, Position position, address user) external view returns (address);
    function getBucketsMask(address underlying, Position position) external view returns (uint256);
}

interface IMorphoAaveV3 is IMorphoAaveV3Getters, IMorphoAaveV3Governance {}
