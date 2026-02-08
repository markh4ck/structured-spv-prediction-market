# Tokenized SPV & Prediction Market Infrastructure
**Developed by Marc Aliaga**

This repository contains a decentralized infrastructure for **Structured Finance** applied to **Prediction Markets**. The project demonstrates how a Special Purpose Vehicle (SPV) can act as a collateralized counterparty to event-driven risks, using a multi-tranche waterfall mechanism to manage investor risk and return.

## 🏗 Project Structure

The project is organized into two main development phases, transitioning from theoretical financial modeling to a full blockchain implementation:

### 📁 `Phase1-Risk_waterfall_simulation/`
Before writing a single line of Solidity, the financial logic was validated through simulation.
* **`premium_distribution.py`**: A Python script used to simulate different market scenarios and validate the **Waterfall Model**. It ensures that the mathematical distribution between Senior, Mezzanine, and Equity tranches behaves correctly under various loss/profit ratios.

### 📁 `Phase2-SmartContracts/`
The core blockchain infrastructure developed using the **Hardhat** framework.
* **`contracts/`**: 
    * `SPV_vault.sol`: The liquidity custodian. Manages capital tranches via ERC-1155 and executes the settlement waterfall.
    * `PredictionMarket.sol`: The application logic. Handles "YES/NO" token minting, solvency checks, and market resolution.
    * `MarketToken.sol`: Standardized ERC-20 implementation used for the settlement currency (USDC) and outcome positions.
* **`ignition/`**: Deployment modules for Hardhat Ignition.
* **`test/`**: Comprehensive test suite to ensure contract security and logical integrity.

### 📁 `Documentation/` & `diagrams/`
* Contains the **Technical Whitepaper** (PDF) and visual architecture diagrams.
* **`SPV-WaterFall.drawio` / `.png`**: Visual representation of the capital flow and seniority levels.

---

## 🛠 Tech Stack
* **Language:** Solidity ^0.8.20 & Python 3.x
* **Framework:** Hardhat
* **Standards:** ERC-20 (Outcome Tokens), ERC-1155 (Investment Tranches)
* **Libraries:** OpenZeppelin (Access Control, Security, Token Standards)

---

## Addresses
✅ USDC Mock desplegado en: 0xb5aA63525769b3355DDfdEb874507fDFB2A279aD

✅ YES Token desplegado en: 0xe8771b0A3C467a0f569FE8Bff68815DAD882770d

✅ NO Token desplegado en: 0xDA942DebdEB8888F6531b57164C76f37722A8f4b

✅ SPV_Vault desplegado en: 0xc9A4B230De730cb139e212150542E9c75Aa87FEA

✅ PredictionMarket desplegado en: 0xd463D1FfBDBEC22a6Fe2C1981C4842A711E13e9A


---

## 👤 Author
**Marc Aliaga**
*Blockchain Developer & DeFi Architect*

---

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
