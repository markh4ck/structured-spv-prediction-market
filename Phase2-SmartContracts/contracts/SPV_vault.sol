// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SPV_Vault is ERC1155, Ownable {
    IERC20 public usdc;
    address public predictionMarket;

    uint256 public constant SENIOR_ID = 0;
    uint256 public constant MEZZANINE_ID = 1;
    uint256 public constant EQUITY_ID = 2;

    uint256 public principalSr;
    uint256 public principalMz;
    uint256 public principalEq;

    uint256 public constant RATE_SR = 5;  
    uint256 public constant RATE_MZ = 12; 

    uint256 public totalPremiums;
    uint256 public totalLoss;
    bool public resolved;

    event Invested(address indexed investor, uint256 tranche, uint256 amount);
    event Claimed(address indexed investor, uint256 tranche, uint256 amount);

    modifier onlyMarket() {
        require(msg.sender == predictionMarket, "Only market can report");
        _;
    }

    constructor(address _usdc) ERC1155("") Ownable(msg.sender) {
        usdc = IERC20(_usdc);
    }

    function setMarket(address _market) external onlyOwner {
        predictionMarket = _market;
    }

    function invest(uint256 amount, uint256 tranche) external {
        require(!resolved, "Market already resolved");
        require(tranche <= 2, "Invalid tranche ID");

        usdc.transferFrom(msg.sender, address(this), amount);
        
        if (tranche == SENIOR_ID) principalSr += amount;
        else if (tranche == MEZZANINE_ID) principalMz += amount;
        else if (tranche == EQUITY_ID) principalEq += amount;

        _mint(msg.sender, tranche, amount, "");
        emit Invested(msg.sender, tranche, amount);
    }

    function claim(uint256 tranche) external {
        require(resolved, "Not resolved yet");
        uint256 tokenBalance = balanceOf(msg.sender, tranche);
        require(tokenBalance > 0, "No tokens to claim");

        (uint256 paySr, uint256 payMz, uint256 payEq) = getPayouts();
        
        uint256 share;
        // Protección contra división por cero y cálculo de parte proporcional
        if (tranche == SENIOR_ID && principalSr > 0) {
            share = (tokenBalance * paySr) / principalSr;
        } else if (tranche == MEZZANINE_ID && principalMz > 0) {
            share = (tokenBalance * payMz) / principalMz;
        } else if (tranche == EQUITY_ID && principalEq > 0) {
            share = (tokenBalance * payEq) / principalEq;
        }

        require(share > 0, "No funds to claim for this tranche");

        _burn(msg.sender, tranche, tokenBalance);
        usdc.transfer(msg.sender, share);

        emit Claimed(msg.sender, tranche, share);
    }

    function totalCollateral() public view returns (uint256) {
        return principalSr + principalMz + principalEq;
    }

    function reportResult(uint256 _loss, uint256 _premiums) external onlyMarket {
        require(!resolved, "Already resolved");
        totalLoss = _loss;
        totalPremiums = _premiums;
        resolved = true;
    }

    function getPayouts() public view returns (uint256 paySr, uint256 payMz, uint256 payEq) {
        require(resolved, "Not resolved yet");
        
        uint256 poolSize = totalCollateral() + totalPremiums;
        uint256 finalPool = poolSize > totalLoss ? poolSize - totalLoss : 0;

        // 1. Pago Senior
        uint256 targetSr = principalSr * (100 + RATE_SR) / 100;
        paySr = finalPool < targetSr ? finalPool : targetSr;

        // 2. Pago Mezzanine
        uint256 remaining = finalPool > paySr ? finalPool - paySr : 0;
        uint256 targetMz = principalMz * (100 + RATE_MZ) / 100;
        payMz = remaining < targetMz ? remaining : targetMz;

        // 3. Pago Equity
        payEq = remaining > payMz ? remaining - payMz : 0;
    }
}