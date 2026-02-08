// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Importamos la interfaz de los tokens que creamos antes
interface IMarketToken {
    function mint(address to, uint256 amount) external;
}

interface IVault {
    function totalCollateral() external view returns (uint256);
    function reportResult(uint256 loss, uint256 premiums) external;
}

contract PredictionMarket {
    IERC20 public usdc;
    IVault public vault;
    IMarketToken public yesToken; // Token ERC20 para el SÍ
    IMarketToken public noToken;  // Token ERC20 para el NO (se queda en el Vault)
    
    address public admin;
    uint256 public deadline;
    uint256 public totalPremiums;
    uint256 public yesTokensSold;
    bool public resolved;

    uint256 public constant YES_PRICE = 0.20 * 1e6; 
    uint256 public constant PAYOUT_PER_YES = 1.00 * 1e6;

    // Añadimos las direcciones de los tokens YES y NO al constructor
    constructor(
        address _usdc, 
        address _vault, 
        address _yesToken, 
        address _noToken, 
        uint256 _duration
    ) {
        usdc = IERC20(_usdc);
        vault = IVault(_vault);
        yesToken = IMarketToken(_yesToken);
        noToken = IMarketToken(_noToken);
        admin = msg.sender;
        deadline = block.timestamp + _duration;
    }

    function buyYes(uint256 quantity) external {
        require(block.timestamp < deadline, "Market closed");
        
        uint256 cost = quantity * YES_PRICE;
        uint256 potentialLiability = quantity * (PAYOUT_PER_YES - YES_PRICE);

        // REGLA DE ORO: Validar colateral disponible
        require(vault.totalCollateral() >= potentialLiability, "SPV: Insufficient collateral");

        // 1. Cobrar USDC
        usdc.transferFrom(msg.sender, address(vault), cost);

        // 2. Entregar el token YES al comprador
        yesToken.mint(msg.sender, quantity);

        // 3. Entregar el token NO al Vault (la apuesta del SPV)
        noToken.mint(address(vault), quantity);

        yesTokensSold += quantity;
        totalPremiums += cost;
    }

    function resolve(bool yesWon) external {
        require(msg.sender == admin, "Only admin");
        require(block.timestamp >= deadline, "Not expired");
        require(!resolved, "Already resolved");

        resolved = true;
        uint256 loss = 0;

        if (yesWon) {
            // El SPV pierde la diferencia entre el payout y lo que ya cobró
            loss = yesTokensSold * (PAYOUT_PER_YES - YES_PRICE);
        }

        vault.reportResult(loss, totalPremiums);
    }
}