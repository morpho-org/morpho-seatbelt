// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

struct MaxGasForMatching {
    uint64 supply;
    uint64 borrow;
    uint64 withdraw;
    uint64 repay;
}

interface IMorphoAaveV2Governance {
    function setMaxSortedUsers(uint256 _newMaxSortedUsers) external;
    function setDefaultMaxGasForMatching(MaxGasForMatching memory _maxGasForMatching) external;
    function setExitPositionsManager(address _exitPositionsManager) external;
    function setEntryPositionsManager(address _entryPositionsManager) external;
    function setInterestRatesManager(address _interestRatesManager) external;
    function setTreasuryVault(address _newTreasuryVaultAddress) external;
    function setIsP2PDisabled(address _poolToken, bool _isP2PDisabled) external;
    function setReserveFactor(address _poolToken, uint256 _newReserveFactor) external;
    function setP2PIndexCursor(address _poolToken, uint16 _p2pIndexCursor) external;
    function setIsPausedForAllMarkets(bool _isPaused) external;
    function setIsSupplyPaused(address _poolToken, bool _isPaused) external;
    function setIsBorrowPaused(address _poolToken, bool _isPaused) external;
    function setIsWithdrawPaused(address _poolToken, bool _isPaused) external;
    function setIsRepayPaused(address _poolToken, bool _isPaused) external;
    function setIsLiquidateCollateralPaused(address _poolToken, bool _isPaused) external;
    function setIsLiquidateBorrowPaused(address _poolToken, bool _isPaused) external;
    function claimToTreasury(address[] calldata _poolTokens, uint256[] calldata _amounts) external;
    function createMarket(address _underlyingToken, uint16 _reserveFactor, uint16 _p2pIndexCursor) external;
    function increaseP2PDeltas(address _poolToken, uint256 _amount) external;
    function setIsDeprecated(address underlying, bool isDeprecated) external;
}

interface IMorphoAaveV2Getter {
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
        uint256 onPool; // In pool borrow unit, a unit that grows in value, to keep track of the debt increase when borrowers are on Aave. Multiply by the pool borrow index to get the underlying amount.
    }

    struct Indexes {
        uint256 p2pSupplyIndex; // The peer-to-peer supply index (in ray), used to multiply the peer-to-peer supply scaled balance and get the peer-to-peer supply balance (in underlying).
        uint256 p2pBorrowIndex; // The peer-to-peer borrow index (in ray), used to multiply the peer-to-peer borrow scaled balance and get the peer-to-peer borrow balance (in underlying).
        uint256 poolSupplyIndex; // The pool supply index (in ray), used to multiply the pool supply scaled balance and get the pool supply balance (in underlying).
        uint256 poolBorrowIndex; // The pool borrow index (in ray), used to multiply the pool borrow scaled balance and get the pool borrow balance (in underlying).
    }

    struct Delta {
        uint256 p2pSupplyDelta; // Difference between the stored peer-to-peer supply amount and the real peer-to-peer supply amount (in pool supply unit).
        uint256 p2pBorrowDelta; // Difference between the stored peer-to-peer borrow amount and the real peer-to-peer borrow amount (in pool borrow unit).
        uint256 p2pSupplyAmount; // Sum of all stored peer-to-peer supply (in peer-to-peer supply unit).
        uint256 p2pBorrowAmount; // Sum of all stored peer-to-peer borrow (in peer-to-peer borrow unit).
    }

    struct AssetLiquidityData {
        uint256 decimals; // The number of decimals of the underlying token.
        uint256 tokenUnit; // The token unit considering its decimals.
        uint256 liquidationThreshold; // The liquidation threshold applied on this token (in basis point).
        uint256 ltv; // The LTV applied on this token (in basis point).
        uint256 underlyingPrice; // The price of the token (in ETH).
        uint256 collateralEth; // The collateral value of the asset (in ETH).
        uint256 debtEth; // The debt value of the asset (in ETH).
    }

    struct LiquidityData {
        uint256 collateralEth; // The collateral value (in ETH).
        uint256 borrowableEth; // The maximum debt value allowed to borrow (in ETH).
        uint256 maxDebtEth; // The maximum debt value allowed before being liquidatable (in ETH).
        uint256 debtEth; // The debt value (in ETH).
    }

    // Variables are packed together to save gas (will not exceed their limit during Morpho's lifetime).
    struct PoolIndexes {
        uint32 lastUpdateTimestamp; // The last time the local pool and peer-to-peer indexes were updated.
        uint112 poolSupplyIndex; // Last pool supply index. Note that for the stEth market, the pool supply index is tweaked to take into account the staking rewards.
        uint112 poolBorrowIndex; // Last pool borrow index. Note that for the stEth market, the pool borrow index is tweaked to take into account the staking rewards.
    }

    struct Market {
        address underlyingToken; // The address of the market's underlying token.
        uint16 reserveFactor; // Proportion of the additional interest earned being matched peer-to-peer on Morpho compared to being on the pool. It is sent to the DAO for each market. The default value is 0. In basis point (100% = 10 000).
        uint16 p2pIndexCursor; // Position of the peer-to-peer rate in the pool's spread. Determine the weights of the weighted arithmetic average in the indexes computations ((1 - p2pIndexCursor) * r^S + p2pIndexCursor * r^B) (in basis point).
        bool isCreated; // Whether or not this market is created.
        bool isPaused; // Deprecated.
        bool isPartiallyPaused; // Deprecated.
        bool isP2PDisabled; // Whether the peer-to-peer market is open or not.
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

    function NO_REFERRAL_CODE() external view returns (uint8);
    function VARIABLE_INTEREST_MODE() external view returns (uint8);
    function MAX_BASIS_POINTS() external view returns (uint16);
    function DEFAULT_LIQUIDATION_CLOSE_FACTOR() external view returns (uint256);
    function HEALTH_FACTOR_LIQUIDATION_THRESHOLD() external view returns (uint256);
    function MAX_NB_OF_MARKETS() external view returns (uint256);
    function BORROWING_MASK() external view returns (bytes32);
    function ONE() external view returns (bytes32);

    function ST_ETH() external view returns (address);
    function ST_ETH_BASE_REBASE_INDEX() external view returns (uint256);

    function isClaimRewardsPaused() external view returns (bool);
    function defaultMaxGasForMatching() external view returns (MaxGasForMatching memory);
    function maxSortedUsers() external view returns (uint256);
    function supplyBalanceInOf(address, address) external view returns (SupplyBalance memory);
    function borrowBalanceInOf(address, address) external view returns (BorrowBalance memory);
    function deltas(address) external view returns (Delta memory);
    function market(address) external view returns (Market memory);
    function marketPauseStatus(address) external view returns (MarketPauseStatus memory);
    function p2pSupplyIndex(address) external view returns (uint256);
    function p2pBorrowIndex(address) external view returns (uint256);
    function poolIndexes(address) external view returns (PoolIndexes memory);
    function interestRatesManager() external view returns (IInterestRatesManager);
    function entryPositionsManager() external view returns (IEntryPositionsManager);
    function exitPositionsManager() external view returns (IExitPositionsManager);
    function addressesProvider() external view returns (ILendingPoolAddressesProvider);
    function pool() external view returns (ILendingPool);
    function treasuryVault() external view returns (address);
    function borrowMask(address) external view returns (bytes32);
    function userMarkets(address) external view returns (bytes32);

    /// UTILS ///

    function updateIndexes(address _poolToken) external;

    /// GETTERS ///

    function getMarketsCreated() external view returns (address[] memory marketsCreated_);
    function getHead(address _poolToken, PositionType _positionType) external view returns (address head);
    function getNext(address _poolToken, PositionType _positionType, address _user)
        external
        view
        returns (address next);
}

interface IMorphoAaveV2 is IMorphoAaveV2Getter, IMorphoAaveV2Governance {}

interface IInterestRatesManager {}

interface IEntryPositionsManager {}

interface IExitPositionsManager {}

interface ILendingPoolAddressesProvider {}

interface ILendingPool {}
