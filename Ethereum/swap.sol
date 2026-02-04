// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnlockContract {
    address public alice;
    address public bob;
    uint256 public lockTime;
    bytes32 public hashPassword;

    constructor(address _alice, address _bob, uint256 _lockTime, bytes32 _hashPassword) payable {
        alice = _alice;
        bob = _bob;
        lockTime = _lockTime;
        hashPassword = _hashPassword;
    }

    // Accept ETH sent to the contract
    receive() external payable {}

    modifier onlyAfterLockTime() {
        require(block.timestamp >= lockTime, "Lock time has not passed yet.");
        _;
    }

    // Function to unlock and transfer funds if Alice signs after lockTime or if Bob provides the correct password hash
    function unlock(bytes memory signature, string memory password) public onlyAfterLockTime {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to claim.");

        // Check if Alice is the signer and the lock time has passed
        if (msg.sender == alice) {
            // Check Alice's signature to verify she is the one signing after lockTime
            require(block.timestamp >= lockTime, "Not yet unlocked.");
            require(verifySignature(signature, alice), "Invalid signature from Alice.");

            // Transfer all contract funds to Alice
            (bool success, ) = alice.call{value: contractBalance}("");
            require(success, "Transfer to Alice failed.");
        }
        // Check if Bob is the signer and provides the correct password hash
        else if (msg.sender == bob) {
            require(verifyPasswordHash(password), "Invalid password.");
            require(verifySignature(signature, bob), "Invalid signature from Bob.");

            // Transfer all contract funds to Bob
            (bool success, ) = bob.call{value: contractBalance}("");
            require(success, "Transfer to Bob failed.");
        }
        else {
            revert("Unauthorized signer.");
        }
    }

    // Helper function to verify the signature
    function verifySignature(bytes memory signature, address signer) private view returns (bool) {
        // Here you would use ecrecover or another method to verify the signature
        // In this case, we're just doing a placeholder verification.
        return signer == msg.sender; // Replace this with actual signature verification logic
    }

    

    // Function to verify if the provided password matches the hash (using SHA-256)
    function verifyPasswordHash(string memory password) private view returns (bool) {
        return sha256(abi.encodePacked(password)) == hashPassword;
    }
}
