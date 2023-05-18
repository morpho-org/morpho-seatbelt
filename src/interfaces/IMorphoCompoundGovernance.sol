// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IMorphoCompoundGovernance {
    struct MaxGasForMatching {
        uint64 supply;
        uint64 borrow;
        uint64 withdraw;
        uint64 repay;
    }

    function setMaxSortedUsers(uint256 _newMaxSortedUsers) external;
    function setDefaultMaxGasForMatching(MaxGasForMatching memory _maxGasForMatching) external;
    function setIncentivesVault(address _newIncentivesVault) external;
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
}
