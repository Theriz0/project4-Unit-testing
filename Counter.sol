// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Counter is ERC20, ERC20Burnable, Ownable {
    uint256 public price;
    uint256 public supply;

    mapping(uint256 => uint256) public previousPrices;
    uint256 public previousPricesIndexCount;

    mapping(address => bool) public vipMembers;

    modifier onlyVip {
        require(vipMembers[msg.sender] == true, "Not a VIP!");
	_;
    }

    constructor(address initialOwner) ERC20("Emerald", "EMR") Ownable(initialOwner) {
	price = 10;
	supply = 100000;
	previousPricesIndexCount = 0;
    }

    // Only VIPs can set the price. We allow for division when setting the price for more flexible prices!
    // The index is increased once for the mapping to be accurate.
    function setPrice(uint256 numerator, uint256 denominator) public onlyVip {
	previousPrices[previousPricesIndexCount] = price;
        price = numerator/denominator;
	previousPricesIndexCount++;
	previousPricesIndexCount++;
    }

    // Passing any index, you can get the price that was set at that point.
    function getPreviousPrice(uint256 priceIndex) public view returns (string memory) {
        return string.concat("Price at index ", Strings.toString(priceIndex), " was: ", Strings.toString(previousPrices[priceIndex]));
    }

    // Only the owner can assign a member to be a VIP.
    function upgradeMemberToVip(address member) public onlyOwner {
        vipMembers[member] = true;
    }

    // Given an index/member returns if that member is a VIP.
    function isMemberVip(address member) public view returns (bool) {
        return vipMembers[member];
    }

    // Event for logging minting information.
    event Log(address sender, address receiver, uint256 amount);

    // Mint function that only VIPs can access.
    // We deduce the minted amount from supply, so you cannot mint if there is no supply left!
    function mint(address to, uint256 amount) public payable onlyVip {
        require(msg.value == price);
        _mint(to, amount);
	supply -= amount;
	emit Log(msg.sender, to, amount);
    }

    // Contract balance to owner
    // Hint: Use fuzz testing for this one.
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
    fallback() external payable {}
}

