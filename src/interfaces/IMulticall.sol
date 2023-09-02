// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IMulticall {
    function multiSend(bytes memory transactions) external payable;
}
