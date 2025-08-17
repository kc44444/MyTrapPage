// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}

contract BalanceAnomalyTrap is ITrap {
    // 👉 Здесь я поставил твой кошелёк
    address public constant target = 0xCCa1BA5359e702e39F5427203b28483C2d4dE603;
    uint256 public constant thresholdPercent = 1; // 1% deviation threshold

    function collect() external override returns (bytes memory) {
        return abi.encode(target.balance);
    }

    function shouldRespond(bytes[] calldata data) external view override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        if (previous == 0) return (false, "No previous data");

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percent = (diff * 100) / previous;

        if (percent >= thresholdPercent) {
            return (true, "");
        }

        return (false, "");
    }
}
