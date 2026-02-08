import pandas as pd

def simulate_spv(principal_sr, principal_mz, principal_eq, premiums, loss_amount, rate_sr=0.05, rate_mz=0.12):
    """
   Tokenized SPV Waterfall distribution.
    
    Args:
        principal_sr (float): Senior Tranche initial capital.
        principal_mz (float): Mezzanine Tranche initial capital.
        principal_eq (float): Equity Tranche initial capital.
        premiums (float): Total premiums collected from 'Yes' buyers (Prediction Market).
        loss_amount (float): Total payout the SPV must pay to market winners.
        rate_sr (float): Fixed interest rate for Senior.
        rate_mz (float): Fixed interest rate for Mezzanine.
    """
    
    # 1. Calculate Initial Total Capital
    total_invested = principal_sr + principal_mz + principal_eq
    
    # 2. Final Cash Pool (Assets + Premiums - Liabilities)
    # This is the money available to be distributed back to investors
    final_pool = max(0, total_invested + premiums - loss_amount)
    
    # 3. SENIOR DISTRIBUTION (Priority 1)
    # They get their principal + fixed interest
    target_sr = principal_sr * (1 + rate_sr)
    payout_sr = min(final_pool, target_sr)
    
    # 4. MEZZANINE DISTRIBUTION (Priority 2)
    # They get what is left, up to their principal + fixed interest
    target_mz = principal_mz * (1 + rate_mz)
    remaining_after_sr = max(0, final_pool - payout_sr)
    payout_mz = min(remaining_after_sr, target_mz)
    
    # 5. EQUITY DISTRIBUTION (Priority 3 / Residual)
    # They get everything that remains in the pool
    payout_eq = max(0, remaining_after_sr - payout_mz)
    
    # 6. Calculate Returns (ROI)
    roi_sr = ((payout_sr / principal_sr) - 1) * 100 if principal_sr > 0 else 0
    roi_mz = ((payout_mz / principal_mz) - 1) * 100 if principal_mz > 0 else 0
    roi_eq = ((payout_eq / principal_eq) - 1) * 100 if principal_eq > 0 else 0
    
    return {
        "1_Final_Pool": final_pool,
        "2_Senior_Payout": payout_sr,
        "3_Mezz_Payout": payout_mz,
        "4_Equity_Payout": payout_eq,
        "5_Senior_ROI_pct": roi_sr,
        "6_Mezz_ROI_pct": roi_mz,
        "7_Equity_ROI_pct": roi_eq
    }

# --- CONFIGURATION (Edit these values) ---
CAPITAL_SR = 700      # Senior Capital
CAPITAL_MZ = 200      # Mezzanine Capital
CAPITAL_EQ = 100      # Equity Capital

PREMIUMS_COLLECTED = 150  # Money from betters
LOSS_PAYOUT = 400         # Money lost in the prediction market


results = simulate_spv(
    CAPITAL_SR, 
    CAPITAL_MZ, 
    CAPITAL_EQ, 
    PREMIUMS_COLLECTED, 
    LOSS_PAYOUT
)

print("-" * 30)
print("SPV WATERFALL SIMULATION")
print("-" * 30)
for key, value in results.items():
    print(f"{key.replace('_', ' ')}: {value:.2f}")