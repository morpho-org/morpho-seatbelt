// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/MorphoDaoTxTest.sol";

contract swapStefanoGuillaumeDaoSignersTxTest is MorphoDaoTxTest {
    address internal constant STEFANO = 0xcE1A723B066B2012550fb473558D6de681F8b5f7;
    address internal constant GUILLAUME = 0x69FcEFDe2B48503d675181448B3D4272128bca9c;

    function _txName() internal pure override returns (string memory) {
        return "swapStefanoGuillaumeDaoSigners";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 18_127_991;
    }

    function testStefanoGuillaumeSwapDaoSigners() public {
        assertFalse(morphoDao.isOwner(STEFANO), "isOwner(STEFANO)");
        assertTrue(morphoDao.isOwner(GUILLAUME), "isOwner(GUILLAUME)");
    }
}
