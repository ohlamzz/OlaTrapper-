// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IFactoryLike {
    function pairCount() external view returns (uint256);
    function allPairsLength() external view returns (uint256);
}

/**
 * NewTokenPairSpamTrap
 *
 * - Uses delta (curr - prev) to decide triggers
 * - Supports pairCount() and allPairsLength() factory methods
 * - Planner-safe: returns 0 fallback and requires two samples
 * - Encodes flagged new-pair count as response argument (uint256)
 */
contract NewTokenPairSpamTrap is ITrap {
    // factory to watch (hardcode or replace before compile/deploy)
    address public immutable TOKEN_FACTORY_ADDRESS = 0x052596695271103f0739B31d7301f0e5DBD9d043;

    // threshold for NEW pairs in the sampling window that will trigger a response
    uint256 public constant THRESHOLD_NEW_PAIRS = 5;

    constructor() {}

    /// collect(): return the total pair count (single uint256 encoded)
    function collect() external view override returns (bytes memory) {
        uint256 totalPairs = _safePairCount(TOKEN_FACTORY_ADDRESS);
        return abi.encode(totalPairs);
    }

    /**
     * shouldRespond expects two samples:
     *   data[0] = newest sample (abi.encode(uint256 totalPairs))
     *   data[1] = previous sample (abi.encode(uint256 totalPairs))
     *
     * Returns (true, abi.encode(newPairs)) when newPairs >= THRESHOLD_NEW_PAIRS
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
// Need at least two samples (newest + previous) and both 32 bytes
        if (data.length < 2 || data[0].length < 32 || data[1].length < 32) {
            return (false, bytes(""));
        }

        uint256 curr = abi.decode(data[0], (uint256)); // newest
        uint256 prev = abi.decode(data[1], (uint256)); // previous

        // factory reset / reorg / noise
        if (curr < prev) {
            return (false, bytes(""));
        }

        uint256 newPairs = curr - prev;
        if (newPairs >= THRESHOLD_NEW_PAIRS) {
            return (true, abi.encode(newPairs));
        }

        return (false, bytes(""));
    }

    /// try pairCount(), fallback to allPairsLength(), else 0
    function _safePairCount(address factory) private view returns (uint256 count) {
        (bool ok1, bytes memory ret1) = factory.staticcall(abi.encodeWithSignature("pairCount()"));
        if (ok1 && ret1.length == 32) {
            return abi.decode(ret1, (uint256));
        }

        (bool ok2, bytes memory ret2) = factory.staticcall(abi.encodeWithSignature("allPairsLength()"));
        if (ok2 && ret2.length == 32) {
            return abi.decode(ret2, (uint256));
        }

        // planner-safe default
        return 0;
    }
}

