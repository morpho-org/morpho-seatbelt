// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

struct MaxGasForMatching {
    uint64 supply;
    uint64 borrow;
    uint64 withdraw;
    uint64 repay;
}

interface IMorphoCompoundGovernance {
    function setMaxSortedUsers(uint256 _newMaxSortedUsers) external;
    function setDefaultMaxGasForMatching(MaxGasForMatching memory _maxGasForMatching) external;
    function setRewardsManager(address _rewardsManagerAddress) external;
    function setPositionsManager(address _positionsManager) external;
    function setInterestRatesManager(address _interestRatesManager) external;
    function setTreasuryVault(address _treasuryVault) external;
    function setDustThreshold(uint256 _dustThreshold) external;
    function setIsP2PDisabled(address _poolToken, bool _isP2PDisabled) external;
    function setReserveFactor(address _poolToken, uint256 _newReserveFactor) external;
    function setP2PIndexCursor(address _poolToken, uint16 _p2pIndexCursor) external;
    function setIsPausedForAllMarkets(bool _isPaused) external;
    function setIsClaimRewardsPaused(bool _isPaused) external;
    function setIsSupplyPaused(address _poolToken, bool _isPaused) external;
    function setIsBorrowPaused(address _poolToken, bool _isPaused) external;
    function setIsWithdrawPaused(address _poolToken, bool _isPaused) external;
    function setIsRepayPaused(address _poolToken, bool _isPaused) external;
    function setIsLiquidateCollateralPaused(address _poolToken, bool _isPaused) external;
    function setIsLiquidateBorrowPaused(address _poolToken, bool _isPaused) external;
    function claimToTreasury(address[] calldata _poolTokens, uint256[] calldata _amounts) external;
    function createMarket(address _poolToken, uint16[2] calldata _params) external;
    function setIsDeprecated(address underlying, bool isDeprecated) external;
}

interface IMorphoCompoundGetters {
    enum PositionType {
        SUPPLIERS_IN_P2P,
        SUPPLIERS_ON_POOL,
        BORROWERS_IN_P2P,
        BORROWERS_ON_POOL
    }

    struct SupplyBalance {
        uint256 inP2P; // In peer-to-peer supply unit, a unit that grows in underlying value, to keep track of the interests earned by suppliers in peer-to-peer. Multiply by the peer-to-peer supply index to get the underlying amount.
        uint256 onPool; // In pool supply unit. Multiply by the pool supply index to get the underlying amount.
    }

    struct BorrowBalance {
        uint256 inP2P; // In peer-to-peer borrow unit, a unit that grows in underlying value, to keep track of the interests paid by borrowers in peer-to-peer. Multiply by the peer-to-peer borrow index to get the underlying amount.
        uint256 onPool; // In pool borrow unit, a unit that grows in value, to keep track of the debt increase when borrowers are on Compound. Multiply by the pool borrow index to get the underlying amount.
    }

    struct Indexes {
        uint256 p2pSupplyIndex; // The peer-to-peer supply index (in wad), used to multiply the peer-to-peer supply scaled balance and get the peer-to-peer supply balance (in underlying).
        uint256 p2pBorrowIndex; // The peer-to-peer borrow index (in wad), used to multiply the peer-to-peer borrow scaled balance and get the peer-to-peer borrow balance (in underlying).
        uint256 poolSupplyIndex; // The pool supply index (in wad), used to multiply the pool supply scaled balance and get the pool supply balance (in underlying).
        uint256 poolBorrowIndex; // The pool borrow index (in wad), used to multiply the pool borrow scaled balance and get the pool borrow balance (in underlying).
    }

    struct Delta {
        uint256 p2pSupplyDelta; // Difference between the stored peer-to-peer supply amount and the real peer-to-peer supply amount (in pool supply unit).
        uint256 p2pBorrowDelta; // Difference between the stored peer-to-peer borrow amount and the real peer-to-peer borrow amount (in pool borrow unit).
        uint256 p2pSupplyAmount; // Sum of all stored peer-to-peer supply (in peer-to-peer supply unit).
        uint256 p2pBorrowAmount; // Sum of all stored peer-to-peer borrow (in peer-to-peer borrow unit).
    }

    struct AssetLiquidityData {
        uint256 collateralUsd; // The collateral value of the asset (in wad).
        uint256 maxDebtUsd; // The maximum possible debt value of the asset (in wad).
        uint256 debtUsd; // The debt value of the asset (in wad).
        uint256 underlyingPrice; // The price of the token.
        uint256 collateralFactor; // The liquidation threshold applied on this token (in wad).
    }

    struct LiquidityData {
        uint256 collateralUsd; // The collateral value (in wad).
        uint256 maxDebtUsd; // The maximum debt value allowed before being liquidatable (in wad).
        uint256 debtUsd; // The debt value (in wad).
    }

    // Variables are packed together to save gas (will not exceed their limit during Morpho's lifetime).
    struct LastPoolIndexes {
        uint32 lastUpdateBlockNumber; // The last time the local pool and peer-to-peer indexes were updated.
        uint112 lastSupplyPoolIndex; // Last pool supply index.
        uint112 lastBorrowPoolIndex; // Last pool borrow index.
    }

    struct MarketParameters {
        uint16 reserveFactor; // Proportion of the interest earned by users sent to the DAO for each market, in basis point (100% = 10 000). The value is set at market creation.
        uint16 p2pIndexCursor; // Position of the peer-to-peer rate in the pool's spread. Determine the weights of the weighted arithmetic average in the indexes computations ((1 - p2pIndexCursor) * r^S + p2pIndexCursor * r^B) (in basis point).
    }

    struct MarketStatus {
        bool isCreated; // Whether or not this market is created.
        bool isPaused; // Deprecated.
        bool isPartiallyPaused; // Deprecated.
    }

    struct MarketPauseStatus {
        bool isSupplyPaused; // Whether the supply is paused or not.
        bool isBorrowPaused; // Whether the borrow is paused or not
        bool isWithdrawPaused; // Whether the withdraw is paused or not. Note that a "withdraw" is still possible using a liquidation (if not paused).
        bool isRepayPaused; // Whether the repay is paused or not. Note that a "repay" is still possible using a liquidation (if not paused).
        bool isLiquidateCollateralPaused; // Whether the liquidation on this market as collateral is paused or not.
        bool isLiquidateBorrowPaused; // Whether the liquidatation on this market as borrow is paused or not.
        bool isDeprecated; // Whether a market is deprecated or not.
    }

    function CTOKEN_DECIMALS() external view returns (uint8);
    function MAX_BASIS_POINTS() external view returns (uint16);
    function WAD() external view returns (uint256);
    function isClaimRewardsPaused() external view returns (bool);
    function defaultMaxGasForMatching() external view returns (MaxGasForMatching memory);
    function maxSortedUsers() external view returns (uint256);
    function dustThreshold() external view returns (uint256);
    function supplyBalanceInOf(address, address) external view returns (SupplyBalance memory);
    function borrowBalanceInOf(address, address) external view returns (BorrowBalance memory);
    function enteredMarkets(address, uint256) external view returns (address);
    function deltas(address) external view returns (Delta memory);
    function marketParameters(address) external view returns (MarketParameters memory);
    function marketPauseStatus(address) external view returns (MarketPauseStatus memory);
    function p2pDisabled(address) external view returns (bool);
    function p2pSupplyIndex(address) external view returns (uint256);
    function p2pBorrowIndex(address) external view returns (uint256);
    function lastPoolIndexes(address) external view returns (LastPoolIndexes memory);
    function marketStatus(address) external view returns (MarketStatus memory);
    function comptroller() external view returns (IComptroller);
    function interestRatesManager() external view returns (IInterestRatesManager);
    function rewardsManager() external view returns (IRewardsManager);
    function positionsManager() external view returns (IPositionsManager);
    function incentivesVault() external view returns (address);
    function treasuryVault() external view returns (address);
    function cEth() external view returns (address);
    function wEth() external view returns (address);
    function getEnteredMarkets(address _user) external view returns (address[] memory);
    function getAllMarkets() external view returns (address[] memory);
    function getHead(address _poolToken, PositionType _positionType) external view returns (address head);
    function getNext(address _poolToken, PositionType _positionType, address _user)
        external
        view
        returns (address next);
}

interface IComptroller {}

interface IInterestRatesManager {}

interface IPositionsManager {}

interface IRewardsManager {}

interface IMorphoCompound is IMorphoCompoundGovernance, IMorphoCompoundGetters {}
