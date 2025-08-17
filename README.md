BalanceTrap

Balance Trap — Drosera Trap SERGEANT

---

## Objective

Create a functional and deployable Drosera trap that:

- Monitors ETH balance anomalies of specific wallet,
- Uses the standard `collect()` / `shouldRespond()` interface,
- Triggers a response when balance deviation exceeds a given threshold (e.g., 1%),
- Integrates with a separate alert contract to handle responses.

---

## Problem

Ethereum wallets involved in DAO treasury, DeFi protocol management, or vesting operations must maintain a stable balance.  
Unexpected change (loss or gain) could indicate compromise, mistake, or exploit.  

✅ **Solution:** Monitor ETH balance across blocks and trigger a response if there’s a significant deviation.

---

## Trap Logic Summary

**Trap Contract: BalanceTrap.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes calldata data) external view returns (bool, bytes memory);
}

contract BalanceTrap is ITrap {
    address public constant target = 0xYOUR_WALLET_ADDRESS; 
    uint256 public constant thresholdPercent = 1;

    function collect() external override returns (bytes memory) {
        return abi.encode(target.balance);
    }

    function shouldRespond(bytes calldata data) external view override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percent = (diff * 100) / previous;

        if (percent >= thresholdPercent) {
            return (true, "");
        }
        return (false, "");
    }
}

