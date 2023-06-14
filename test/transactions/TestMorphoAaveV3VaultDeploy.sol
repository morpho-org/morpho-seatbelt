// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestSetup.sol";
import {IMorphoAaveV3SupplyVault} from "src/interfaces/IMorphoAaveV3SupplyVault.sol";
import {Ownable2Step} from "@openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract TestMorphoAaveV3VaultDeploy is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    IMorphoAaveV3SupplyVault internal vault = IMorphoAaveV3SupplyVault(0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b);
    IMorphoAaveV3SupplyVault internal implementation =
        IMorphoAaveV3SupplyVault(0xb1c23d9ca977aB301417332Def6f91AcBD410A96);
    address internal WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public virtual override {
        super.setUp();
        _addModule(IAvatar(morphoAssociation), address(this));
        _execute("testVaultDeploy");
    }

    function _execute(string memory txName) internal virtual {
        Transaction memory transaction = _getTxData(txName);
        morphoAssociation.execTransactionFromModule(
            transaction.to, transaction.value, transaction.data, transaction.operation
        );
    }

    function testAssertions() public virtual {
        assertEq(Ownable2Step(address(vault)).pendingOwner(), address(morphoAdmin));

        assertEq(vault.MORPHO(), address(morphoAaveV3));
        assertEq(vault.asset(), WETH);
        assertEq(vault.recipient(), address(0));
        assertEq(vault.maxIterations(), 4);
        assertEq(vault.name(), "AaveV3-ETH Optimizer Supply Vault WETH");
        assertEq(vault.symbol(), "ma3WETH");
        assertEq(vault.decimals(), 18);

        assertApproxEqAbs(vault.totalAssets(), 1e9, 2);

        assertApproxEqAbs(vault.balanceOf(address(0xdead)), 1e9, 2);
        assertEq(vault.balanceOf(address(0xdead)), vault.totalSupply());

        vm.startPrank(address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).admin(), address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).implementation(), address(implementation));
        vm.stopPrank();
    }
}
