// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

import {Transaction, Operation} from "src/libraries/Types.sol";

contract TestTransaction is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    Config internal txConfig;

    function setUp() public virtual override {
        super.setUp();
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));
        Transaction memory transaction = _getTxData("default");
        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.op);
    }

    function _getTxData(string memory txName) internal returns (Transaction memory transaction) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config/transactions/", txName, ".json");
        txConfig.json = vm.readFile(path);
        transaction.to = txConfig.getAddress("to");
        transaction.value = txConfig.getUint("value");
        transaction.data = txConfig.getBytes("data");
        transaction.op = txConfig.getBool("op") ? Operation.DelegateCall : Operation.Call;
    }

    function testAssert() public {
        // Do assertions here
        assertTrue(roleModifier.members(1, address(operator)));
    }
}
