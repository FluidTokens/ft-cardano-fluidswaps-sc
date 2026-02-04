// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract UnlockContract {
    address public alice;
    address public bob;
    uint256 public lockTime;
    bytes32 public hashPassword;
    address public tokenAddress; // address(0) = ETH, otherwise ERC-20

    constructor(
        address _alice,
        address _bob,
        uint256 _lockTime,
        bytes32 _hashPassword,
        address _tokenAddress
    ) payable {
        alice = _alice;
        bob = _bob;
        lockTime = _lockTime;
        hashPassword = _hashPassword;
        tokenAddress = _tokenAddress;
    }

    // Accept ETH sent to the contract (only when in ETH mode)
    receive() external payable {
        require(tokenAddress == address(0), "Contract is in ERC-20 mode.");
    }

    // Deposit ERC-20 tokens into the contract
    function depositToken(uint256 amount) external {
        require(tokenAddress != address(0), "Contract is in ETH mode.");
        require(
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount),
            "Token transfer failed."
        );
    }

    modifier onlyAfterLockTime() {
        require(block.timestamp >= lockTime, "Lock time has not passed yet.");
        _;
    }

    // Function to unlock and transfer funds if Alice signs after lockTime or if Bob provides the correct password hash
    function unlock(bytes memory signature, string memory password) public onlyAfterLockTime {
        uint256 contractBalance = _getBalance();
        require(contractBalance > 0, "No funds to claim.");

        // Check if Alice is the signer and the lock time has passed
        if (msg.sender == alice) {
            require(block.timestamp >= lockTime, "Not yet unlocked.");
            require(verifySignature(signature, alice), "Invalid signature from Alice.");

            _transfer(alice, contractBalance);
        }
        // Check if Bob is the signer and provides the correct password hash
        else if (msg.sender == bob) {
            require(verifyPasswordHash(password), "Invalid password.");
            require(verifySignature(signature, bob), "Invalid signature from Bob.");

            _transfer(bob, contractBalance);
        }
        else {
            revert("Unauthorized signer.");
        }
    }

    function _getBalance() private view returns (uint256) {
        if (tokenAddress == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(tokenAddress).balanceOf(address(this));
        }
    }

    function _transfer(address to, uint256 amount) private {
        if (tokenAddress == address(0)) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "ETH transfer failed.");
        } else {
            require(IERC20(tokenAddress).transfer(to, amount), "Token transfer failed.");
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
