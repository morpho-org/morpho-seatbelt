// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "test/TestTransactionSetup.sol";
import {IMorphoAaveV3SupplyVault} from "src/interfaces/IMorphoAaveV3SupplyVault.sol";
import {Ownable2Step} from "@openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TestMA3WETHDeployment is TestTransactionSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    IMorphoAaveV3SupplyVault internal vault = IMorphoAaveV3SupplyVault(0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b);
    IMorphoAaveV3SupplyVault internal implementation =
        IMorphoAaveV3SupplyVault(0xb1c23d9ca977aB301417332Def6f91AcBD410A96);
    IERC20 internal WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public virtual override {
        super.setUp();
        _addModule(IAvatar(morphoAssociation), address(this));
        _execute("ma3WETHDeployment");
    }

    function _network() internal view virtual override returns (string memory) {
        return "ethereum-mainnet";
    }

    function _forkBlockNumber() internal virtual override returns (uint256) {
        return 17478410;
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
        assertEq(vault.asset(), address(WETH));
        assertEq(vault.recipient(), address(0));
        assertEq(vault.maxIterations(), 4);
        assertEq(vault.name(), "AaveV3-ETH Optimizer Supply Vault WETH");
        assertEq(vault.symbol(), "ma3WETH");
        assertEq(vault.decimals(), 18);
        assertEq(WETH.allowance(address(vault), address(morphoAaveV3)), type(uint256).max);

        console.log("begin");
        assertApproxEqAbs(vault.totalAssets(), 1e9, 2);
        console.log("done");
        assertApproxEqAbs(vault.balanceOf(address(0xdead)), 1e9, 2);
        console.log("finish");
        assertEq(vault.balanceOf(address(0xdead)), vault.totalSupply());

        vm.startPrank(address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).admin(), address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).implementation(), address(implementation));
        vm.stopPrank();
    }
}
