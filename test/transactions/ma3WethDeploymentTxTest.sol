// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMorphoAaveV3SupplyVault} from "src/interfaces/IMorphoAaveV3SupplyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "./helpers/MorphoAssociationTxTest.sol";

contract ma3WETHDeploymentTxTest is MorphoAssociationTxTest {
    using ConfigLib for Config;

    IMorphoAaveV3SupplyVault internal vault = IMorphoAaveV3SupplyVault(0x39Dd7790e75C6F663731f7E1FdC0f35007D3879b);
    IMorphoAaveV3SupplyVault internal implementation =
        IMorphoAaveV3SupplyVault(0xb1c23d9ca977aB301417332Def6f91AcBD410A96);
    IERC20 internal WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function _txName() internal pure override returns (string memory) {
        return "ma3WethDeployment";
    }

    function _forkBlockNumber() internal pure override returns (uint256) {
        return 17_478_410;
    }

    function testMa3WETHDeployment() public {
        assertEq(Ownable2Step(address(vault)).pendingOwner(), address(morphoAdmin));

        assertEq(vault.MORPHO(), address(morphoAaveV3));
        assertEq(vault.asset(), address(WETH));
        assertEq(vault.recipient(), address(0));
        assertEq(vault.maxIterations(), 4);
        assertEq(vault.name(), "AaveV3-ETH Optimizer Supply Vault WETH");
        assertEq(vault.symbol(), "ma3WETH");
        assertEq(vault.decimals(), 18);
        assertEq(WETH.allowance(address(vault), address(morphoAaveV3)), type(uint256).max);

        assertApproxEqAbs(vault.totalAssets(), 1e9, 2);
        assertApproxEqAbs(vault.balanceOf(address(0xdead)), 1e9, 2);
        assertEq(vault.balanceOf(address(0xdead)), vault.totalSupply());

        vm.startPrank(address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).admin(), address(proxyAdmin));
        assertEq(ITransparentUpgradeableProxy(address(vault)).implementation(), address(implementation));
        vm.stopPrank();
    }
}
