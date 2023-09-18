// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ArrayLib {
    function contains(bytes4[] storage selectors, bytes4 selector) internal view returns (bool) {
        for (uint256 i; i < selectors.length; ++i) {
            if (selector == selectors[i]) {
                return true;
            }
        }
        return false;
    }
}
