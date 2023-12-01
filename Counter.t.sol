// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    // Setting up the contract reference to be used in tests.
    Counter public counter;

    // Dummy address for Counter constructor.
    address ownerAddress = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    // Setup for all tests.
    function setUp() public {
        counter = new Counter(ownerAddress);
    }

    // Example test case for testing the initial price.
    function test_InitialPrice() public {
        assertEq(counter.price(), 10);
    }

    // Use vm.prank with the owner's address to access onlyOwner modifiers.
    // Same with onlyVip.

    // TODO: Rest of the tests using both assertion and fuzzing testing.

    // Test setPrice function with valid input for onlyVip
    function test_SetPrice_OnlyVip() public {
        // Upgrade sender to VIP
        vm.prank(ownerAddress);
        counter.upgradeMemberToVip(ownerAddress);
        vm.prank(ownerAddress);
        // Call setPrice
        counter.setPrice(5, 3);
        // Check if the price was set correctly
        assertEq(counter.price(), 1);
    }

    // Test getPreviousPrice function
    function test_GetPreviousPrice() public {
        // Set prices directly in previousPrices
        counter.getPreviousPrice(5);
        counter.getPreviousPrice(3);

        // Call getPreviousPrice and check the result
        string memory result = counter.getPreviousPrice(0);
        assertEq(result, "Price at index 0 was: 5");

        result = counter.getPreviousPrice(1);
        assertEq(result, "Price at index 1 was: 3");
    }

    // Test upgradeMemberToVip function
    function test_UpgradeMemberToVip() public {
        // Prank the owner's address to act as the onlyOwner
        vm.prank(ownerAddress);
        counter.upgradeMemberToVip(ownerAddress);
        vm.prank(ownerAddress);

        // Check if non-owner address is VIP (should not be VIP)
        address nonOwner = address(0x1234567890123456789012345678901234567890);
        assertEq(counter.isMemberVip(nonOwner), false,
        "Non-owner should not be VIP");
    }

    // Test isMemberVip function
    function test_IsMemberVip() public {
        // Check if owner is VIP (should be VIP)
        assertEq(counter.isMemberVip(ownerAddress), false,
        "Owner should not be VIP initially");

        // Upgrade owner to VIP
        vm.prank(ownerAddress);
        counter.upgradeMemberToVip(ownerAddress);
        vm.prank(ownerAddress);
        assertEq(counter.isMemberVip(ownerAddress), true,
        "Owner should be VIP after upgrade");
    }

    // Test mint function with valid input for onlyVip
    function test_Mint_OnlyVip() public {

        // Mint as VIP
        uint256 mintAmount = 5;
        uint256 initialSupply = counter.supply();

        vm.prank(ownerAddress);
        counter.upgradeMemberToVip(ownerAddress);
        vm.prank(ownerAddress);
        counter.mint(ownerAddress, mintAmount);

        // Check if supply was correctly reduced
        assertEq(counter.supply(), initialSupply - mintAmount,
        "Supply should be reduced after minting");
    }

    /*function testFuzz_Withdraw(uint256 amount) public {
        uint256 fuzzAmount = 222;

        // Make the sender address the owner for the test
        vm.prank(ownerAddress);

        payable(address(safe)).transfer(amount);

        uint256 preBalance = address(this).balance;
        safe.withdraw();

        uint256 postBalance = address(this).balance;
        assertEq(preBalance + fuzzAmount, postBalance);
    }*/
}
