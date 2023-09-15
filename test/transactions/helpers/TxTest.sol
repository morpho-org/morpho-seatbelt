// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAvatar, Operation} from "src/interfaces/IAvatar.sol";

import "../../helpers/ForkTest.sol";
import "../../DaoTest.sol";
import "../../RoleModifierTest.sol";
import "../../MorphoTokenTest.sol";

struct Tx {
    bytes data;
    Operation operation;
    address to;
    uint256 value;
}

abstract contract TxTest is ForkTest, DaoTest, RoleModifierTest, MorphoTokenTest {
    using stdJson for string;
    using ConfigLib for Config;

    IAvatar[] internal avatars;

    function setUp() public virtual {
        uint256 nbAvatars = avatars.length;
        for (uint256 i; i < nbAvatars; ++i) {
            _enableThisModule(avatars[i]);
        }

        _execute(_loadTx());
    }

    function _txName() internal virtual returns (string memory);

    function _execute(Tx memory transaction) internal virtual;

    /// @dev So we can just call execTransactionFromModule to simulate executing transactions without signatures.
    function _enableThisModule(IAvatar avatar) internal virtual {
        vm.prank(address(avatar));
        avatar.enableModule(address(this));
    }

    function _loadTx() internal returns (Tx memory transaction) {
        string memory path = string.concat("test/transactions/data/", _txName(), ".json");

        string memory json = vm.readFile(path);

        bytes memory encodedTx = json.parseRaw("$");

        return abi.decode(encodedTx, (Tx));
    }
}
