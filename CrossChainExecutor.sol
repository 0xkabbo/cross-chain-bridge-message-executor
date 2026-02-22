// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CrossChainExecutor
 * @dev Professional implementation for receiving and executing cross-chain messages.
 */
contract CrossChainExecutor is Ownable {
    
    // Mapping to store trusted remote addresses (ChainId => SourceContractAddress)
    mapping(uint32 => address) public trustedRemotes;

    event MessageReceived(uint32 srcChainId, address srcAddress, bytes payload);
    event ActionExecuted(address target, bool success);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Sets the trusted source contract for a specific chain.
     */
    function setTrustedRemote(uint32 _srcChainId, address _srcAddress) external onlyOwner {
        trustedRemotes[_srcChainId] = _srcAddress;
    }

    /**
     * @dev Simulates the entry point for a cross-chain message.
     * In a real scenario, this would be called by a Bridge Provider (e.g., LayerZero/CCIP).
     */
    function executeCrossChainMessage(
        uint32 _srcChainId,
        bytes calldata _srcAddress,
        bytes calldata _payload
    ) external {
        // 1. Security Check: Validate the source
        address srcAddress = abi.decode(_srcAddress, (address));
        require(srcAddress == trustedRemotes[_srcChainId], "Source not trusted");

        // 2. Decode the Payload
        // Expected payload format: (address target, uint256 value, bytes data)
        (address target, uint256 value, bytes memory data) = abi.decode(_payload, (address, uint256, bytes));

        // 3. Execute the call
        (bool success, ) = target.call{value: value}(data);
        
        emit MessageReceived(_srcChainId, srcAddress, _payload);
        emit ActionExecuted(target, success);
        
        require(success, "Execution failed");
    }

    receive() external payable {}
}
