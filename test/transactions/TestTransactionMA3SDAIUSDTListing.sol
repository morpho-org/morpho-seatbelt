// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IMulticall} from "src/interfaces/IMulticall.sol";
import {Operation} from "src/libraries/Types.sol";
import "test/TestTransactionSetup.sol";

contract TestTransactionMA3SDAIUSDTListing is TestTransactionSetup {
    IMulticall internal constant multicall = IMulticall(0x40A2aCCbd92BCA938b02010E17A5b8929b49130D);
    address internal constant S_DAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant A_S_DAI = 0x4C612E3B15b96Ff9A6faED838F8d07d479a8dD4c;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant A_S_DAI_HOLDER = 0x66B870dDf78c975af5Cd8EDC6De25eca81791DE1;

    function setUp() public virtual override {
        super.setUp();

        // Cannot set as collateral in current iteration of aave with 0 collateral balance
        vm.prank(A_S_DAI_HOLDER);
        Token(A_S_DAI).transfer(address(morphoAaveV3), 1 ether);

        // The encoded calls of all the transactions
        bytes[] memory transactions = _buildTransactions();
        // The data to use in the multisend
        bytes memory multisendData = _concatMultisendTx("", address(morphoAaveV3), 0, transactions);
        vm.prank(address(delayModifier));
        morphoAdmin.execTransactionFromModule(address(multicall), 0, multisendData, Operation.DelegateCall);
    }

    function _concatMultisendTx(bytes memory data, address to, uint256 value, bytes[] memory transactions)
        internal
        pure
        returns (bytes memory)
    {
        for (uint256 i; i < transactions.length; i++) {
            data = bytes.concat(data, _buildMultisendTx(to, value, transactions[i]));
        }
        return abi.encodeCall(multicall.multiSend, (data));
    }

    function _buildMultisendTx(address to, uint256 value, bytes memory transaction)
        internal
        pure
        returns (bytes memory data)
    {
        return abi.encodePacked(uint8(0), to, value, transaction.length, transaction);
    }

    function _buildTransactions() internal view returns (bytes[] memory transactions) {
        transactions = new bytes[](18);
        {
            transactions[0] = abi.encodeCall(morphoAaveV3.createMarket, (S_DAI, 0, 0));
            transactions[1] = abi.encodeCall(morphoAaveV3.setAssetIsCollateralOnPool, (S_DAI, true));
            transactions[2] = abi.encodeCall(morphoAaveV3.setAssetIsCollateral, (S_DAI, true));
            transactions[3] = abi.encodeCall(morphoAaveV3.setIsSupplyPaused, (S_DAI, true));
            transactions[4] = abi.encodeCall(morphoAaveV3.setIsWithdrawPaused, (S_DAI, true));
            transactions[5] = abi.encodeCall(morphoAaveV3.setIsBorrowPaused, (S_DAI, true));
            transactions[6] = abi.encodeCall(morphoAaveV3.setIsRepayPaused, (S_DAI, true));
            transactions[7] = abi.encodeCall(morphoAaveV3.setIsLiquidateBorrowPaused, (S_DAI, true));
            transactions[8] = abi.encodeCall(morphoAaveV3.setIsP2PDisabled, (S_DAI, true));
        }

        {
            transactions[9] = abi.encodeCall(morphoAaveV3.createMarket, (USDT, 0, 0));
            transactions[10] = abi.encodeCall(morphoAaveV3.setAssetIsCollateralOnPool, (USDT, true));
            transactions[11] = abi.encodeCall(morphoAaveV3.setAssetIsCollateral, (USDT, true));
            transactions[12] = abi.encodeCall(morphoAaveV3.setIsSupplyPaused, (USDT, true));
            transactions[13] = abi.encodeCall(morphoAaveV3.setIsWithdrawPaused, (USDT, true));
            transactions[14] = abi.encodeCall(morphoAaveV3.setIsBorrowPaused, (USDT, true));
            transactions[15] = abi.encodeCall(morphoAaveV3.setIsRepayPaused, (USDT, true));
            transactions[16] = abi.encodeCall(morphoAaveV3.setIsLiquidateBorrowPaused, (USDT, true));
            transactions[17] = abi.encodeCall(morphoAaveV3.setIsP2PDisabled, (USDT, true));
        }
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 18_035_438;
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
