// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAvatar} from "src/interfaces/IAvatar.sol";

import {Operation, Transaction} from "src/libraries/Types.sol";

import {Config, ConfigLib} from "config/ConfigLib.sol";
import {StdChains, VmSafe} from "@forge-std/StdChains.sol";

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract Configured is StdChains {
    using ConfigLib for Config;

    error InvalidOperation();

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    Chain internal chain;
    Config internal networkConfig;
    Config internal txConfig;

    function unwrapTxData(bytes calldata data) external pure returns (Transaction memory transaction) {
        (transaction.to, transaction.value, transaction.data, transaction.operation) =
            abi.decode(data[4:], (address, uint256, bytes, Operation));
    }

    function _network() internal view virtual returns (string memory) {
        try vm.envString("NETWORK") returns (string memory network) {
            return network;
        } catch {
            return "ethereum-mainnet";
        }
    }

    function _txName() internal view virtual returns (string memory) {
        try vm.envString("TX_NAME") returns (string memory transactionName) {
            return transactionName;
        } catch {
            return "test";
        }
    }

    function _initConfig() internal returns (Config storage) {
        if (bytes(networkConfig.json).length == 0) {
            string memory root = vm.projectRoot();
            string memory path = string.concat(root, "/config/networks/", _network(), ".json");

            networkConfig.json = vm.readFile(path);
        }

        return networkConfig;
    }

    function _loadConfig() internal virtual {
        string memory rpcAlias = networkConfig.getRpcAlias();

        chain = getChain(rpcAlias);
    }

    function _wrapTxData(Transaction memory transaction) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            IAvatar.execTransactionFromModule.selector,
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.operation
        );
    }

    /// @dev Slicing bytes array data is only possible with bytes in calldata, but internal functions cannot create calldata.
    ///      So we work around this by doing an external call on this contract to force the data to be in calldata.
    function _unwrapTxData(bytes memory data) internal view returns (Transaction memory) {
        return this.unwrapTxData(data);
    }

    function unwrapTxData(bytes calldata data) external pure returns (Transaction memory transaction) {
        (transaction.to, transaction.value, transaction.data, transaction.operation) = abi.decode(data[4:], (address, uint256, bytes, Operation));
    }

    function _getSelector(bytes memory data) internal pure returns (bytes4 selector) {
        assembly {
            selector := mload(add(data, 32))
        }
    }

    function _getTxData(string memory txName) internal returns (Transaction memory transaction) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config/transactions/", txName, ".json");
        txConfig.json = vm.readFile(path);
        transaction.to = txConfig.getAddress("to");
        transaction.value = txConfig.getUint("value");
        transaction.data = txConfig.getBytes("data");

        uint256 operation = txConfig.getUint("operation");
        if (operation == 0) transaction.operation = Operation.Call;
        else if (operation == 1) transaction.operation = Operation.DelegateCall;
        else revert InvalidOperation();
    }
}
