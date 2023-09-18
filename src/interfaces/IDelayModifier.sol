// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import {IAvatar, Operation} from "./IAvatar.sol";
import {IModule} from "./IModule.sol";

interface IDelayModifier is IAvatar, IModule {
    function setUp(bytes memory initParams) external;
    function setTxCooldown(uint256 cooldown) external;
    function setTxExpiration(uint256 expiration) external;
    function setTxNonce(uint256 _nonce) external;
    function executeNextTx(address to, uint256 value, bytes calldata data, Operation operation) external;
    function skipExpired() external;

    function txCooldown() external view returns (uint256);
    function txExpiration() external view returns (uint256);
    function txNonce() external view returns (uint256);
    function queueNonce() external view returns (uint256);
    function txHash(uint256 nonce) external view returns (bytes32);
    function txCreatedAt(uint256 nonce) external view returns (uint256);
    function getTransactionHash(address to, uint256 value, bytes memory data, Operation operation)
        external
        pure
        returns (bytes32);
    function getTxHash(uint256 _nonce) external view returns (bytes32);
    function getTxCreatedAt(uint256 _nonce) external view returns (uint256);
}
