// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IMulticall {
    function multiSend(bytes memory transactions) external payable;
}
