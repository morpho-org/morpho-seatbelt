// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestTransactionSetup.sol";
import "src/interfaces/IOwnerManager.sol";

import {Ownable2Step} from "@openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract TestTransactionSwapMultisigSigners is TestTransactionSetup {
    address internal constant oldOwner = 0xcE1A723B066B2012550fb473558D6de681F8b5f7;
    address internal constant newOwner = 0x69FcEFDe2B48503d675181448B3D4272128bca9c;

    function setUp() public virtual override {
        super.setUp();
         _executeDAOTestTransaction("swapMultisigSigners");
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 18127500;
    }

    function testAssertionsOfTransaction() public virtual {
        assertTrue(morphoDao.isOwner(newOwner));
        assertFalse(morphoDao.isOwner(oldOwner));
    }
}
