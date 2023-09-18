# Morpho Seatbelt

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://i.imgur.com/uLq5V14.png">
  <img alt="" src="https://i.imgur.com/ZiL1Lr2.png">
</picture>

---

## Overview

Morpho Seatbelt provides a framework for testing governance transactions to update any contract controlled (directly or indirectly) by the Morpho DAO. Morpho uses the [Zodiac](https://github.com/gnosis/zodiac) collection of tools to enforce transaction delays and restrict certain functions to addresses with an appropriate role. Some key utilities included are reading gnosis safe transactions from a json, reading key internal state variables of contracts without external getters, and minimal interfaces to limit dependencies. 


---

## Development

### Getting Started

- Install [Foundry](https://github.com/foundry-rs/foundry) or Run `foundryup` to initialize Foundry.
- Run `yarn` to initialize the repository by installing the required dependencies.
- Create a `.env` file with a `ALCHEMY_KEY` field populated with a personal alchemy RPC key.

### Running tests

- Use `yarn test` to run tests on standard invariants regarding the Morpho DAO & the $MORPHO token setup.
- Use `yarn test:txs` to run tests on specific DAO transactions.

### Testing a DAO transaction

#### Testing a transaction through the Delay Modifier

- Copy the parameters of the call from the DAO to the delay modifier's `execTransactionFromModule` to a [json file appropriately named](./test/transactions/data/).
- Create a test contract that inherits from `DelayModifierTxTest` (see examples: [ma3CbEthListingTxTest](./test/transactions/ma3CbEthListingTxTest.sol), [ma3REthListingTxTest](./test/transactions/ma3REthListingTxTest.sol), [ma3SDaiUsdtListingTxTest](./test/transactions/ma3SDaiUsdtListingTxTest.sol)).

#### Testing a transaction to the Morpho DAO

- Copy the transaction data to a [json file appropriately named](./test/transactions/data/).
- Create a test contract that inherits from `MorphoDaoTxTest` (see example: [swapStefanoGuillaumeDaoSignersTxTest](./test/transactions/swapStefanoGuillaumeDaoSignersTxTest.sol)).

## Questions & Feedback

For any questions or feedbacks, you can join the Morpho [discord](https://discord.morpho.xyz).

---

## Licensing

The code is under the MIT License, see [`LICENSE`](./LICENSE).
