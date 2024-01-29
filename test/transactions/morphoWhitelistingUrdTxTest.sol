// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/MorphoDaoTxTest.sol";

contract morphoWhitelistingUrdTxTest is MorphoDaoTxTest {
    address internal constant URD = 0x678dDC1d07eaa166521325394cDEb1E4c086DF43;

    function _txName() internal pure override returns (string memory) {
        return "morphoWhitelistingUrd";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 19_113_282;
    }

    function testMorphoWhitelistingUrd() public {
        assertTrue(morphoToken.doesUserHaveRole(URD, uint8(0)), "doesUserHaveRole(URD, uint8(0))");
    }
}
