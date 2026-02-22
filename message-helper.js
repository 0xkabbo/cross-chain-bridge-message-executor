const { ethers } = require("ethers");

/**
 * Helper to encode cross-chain payloads for the CrossChainExecutor
 */
function encodePayload(targetAddress, valueInWei, dataHex) {
    const abiCoder = new ethers.AbiCoder();
    return abiCoder.encode(
        ["address", "uint256", "bytes"],
        [targetAddress, valueInWei, dataHex]
    );
}

const target = "0x1234567890123456789012345678901234567890";
const payload = encodePayload(target, 0, "0x");
console.log("Encoded Payload:", payload);
