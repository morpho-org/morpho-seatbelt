# Morpho Seatbelt

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://i.imgur.com/uLq5V14.png">
  <img alt="" src="https://i.imgur.com/ZiL1Lr2.png">
</picture>

---

## Overview

Morpho Seatbelt provides a framework for testing governance transactions to update Morpho Optimizers. Morpho utilizes the [Zodiac](https://github.com/gnosis/zodiac) collection of tools to enforce transaction delays and restrict certain functions to addresses with an appropriate role. Some key utilities included are reading gnosis safe transactions from a json, reading key internal state variables of contracts without external getters, and minimal interfaces to limit dependencies. 


---

## Development

### Getting Started

- Install [Foundry](https://github.com/foundry-rs/foundry).
- If not testing on mainnet, add a config file in the [network config](./config/networks) using the mainnet config as a template, and create a `.env` file with a NETWORK field.
- If testing a safe transaction on the Morpho DAO, add the transaction information in the [transactions config](./config/transactions). You can use [this](./test/TestLog.sol) as a template. 


## Questions & Feedback

For any question or feedback you can join the Morpho [discord](https://discord.gg/BWXbJMHMdz).

---

## Licensing

The code is under the MIT License, see [`LICENSE`](./LICENSE).