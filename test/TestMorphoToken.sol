// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetUp.sol";

contract TestMorphoToken is TestTransactionSetUp {
    // Sense whitelisted addresses https://forum.morpho.xyz/t/whitelisted-morpho-transfers-for-sense-integration/151
    address public constant SENSE_REWARDS_DISTRIBUTOR = 0x6bce2D632fc8a327e6Ea353b028999bfCbCb6fcD;
    address public constant MA_DAI_SENSE_ADAPTER = 0x9887e67AaB4388eA4cf173B010dF5c92B91f55B5;
    address public constant MA_USDC_SENSE_ADAPTER = 0x529c90E6d3a1AedaB9B3011196C495439D23b893;
    address public constant MA_USDT_SENSE_ADAPTER = 0x8c5e7301a012DC677DD7DaD97aE44032feBCD0FD;

    function testOwner() public {
        assertEq(morphoToken.owner(), address(morphoDao));
    }

    function testRole0() public {
        assertTrue(morphoToken.doesRoleHaveCapability(0, Token.transfer.selector));
        assertTrue(morphoToken.doesRoleHaveCapability(0, Token.transferFrom.selector));
        assertFalse(morphoToken.doesRoleHaveCapability(0, Token.mint.selector));
        assertFalse(morphoToken.doesRoleHaveCapability(0, Token.burn.selector));

        assertFalse(morphoToken.doesRoleHaveCapability(1, Token.transfer.selector));
        assertFalse(morphoToken.doesRoleHaveCapability(1, Token.transferFrom.selector));
        assertFalse(morphoToken.doesRoleHaveCapability(1, Token.mint.selector));
        assertFalse(morphoToken.doesRoleHaveCapability(1, Token.burn.selector));

        assertFalse(morphoToken.isCapabilityPublic(Token.transfer.selector));
        assertFalse(morphoToken.isCapabilityPublic(Token.transferFrom.selector));
        assertFalse(morphoToken.isCapabilityPublic(Token.mint.selector));
        assertFalse(morphoToken.isCapabilityPublic(Token.burn.selector));
    }

    function testAddressWithRole0() public {
        // Morpho DAO does not have the role since it is the owner.
        assertFalse(morphoToken.doesUserHaveRole(address(morphoDao), 0));

        // Morpho related Safe contracts.
        assertTrue(morphoToken.doesUserHaveRole(address(morphoLabs), 0));
        assertTrue(morphoToken.doesUserHaveRole(address(morphoAssociation), 0));
        assertTrue(morphoToken.doesUserHaveRole(address(rewardsDistributorCore), 0));
        assertTrue(morphoToken.doesUserHaveRole(address(rewardsDistributorVaults), 0));

        // Vaults.
        assertTrue(morphoToken.doesUserHaveRole(maWBTC, 0));
        assertTrue(morphoToken.doesUserHaveRole(maUSDC, 0));
        assertTrue(morphoToken.doesUserHaveRole(maUSDT, 0));
        assertTrue(morphoToken.doesUserHaveRole(maCRV, 0));
        assertTrue(morphoToken.doesUserHaveRole(maWETH, 0));
        assertTrue(morphoToken.doesUserHaveRole(maDAI, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcWTBC, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcUSDT, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcUSDC, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcUNI, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcCOMP, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcWETH, 0));
        assertTrue(morphoToken.doesUserHaveRole(mcDAI, 0));

        // Sense contracts.
        assertTrue(morphoToken.doesUserHaveRole(SENSE_REWARDS_DISTRIBUTOR, 0));
        assertTrue(morphoToken.doesUserHaveRole(MA_DAI_SENSE_ADAPTER, 0));
        assertTrue(morphoToken.doesUserHaveRole(MA_USDC_SENSE_ADAPTER, 0));
        assertTrue(morphoToken.doesUserHaveRole(MA_USDT_SENSE_ADAPTER, 0));
    }
}
