// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestMorphoToken is TestSetup {
	function testOwner() public {
		assertEq(morphoToken.owner(), address(morphoDao));
	}

	function testRole0() public{
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
}