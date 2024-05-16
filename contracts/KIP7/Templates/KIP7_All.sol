// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Core/KIP7.sol";
import "../Extensions/KIP7Burnable.sol";
import "../Extensions/KIP7Mintable.sol";
import "../Extensions/KIP7Metadata.sol";
import "../Extensions/KIP7Pausable.sol";

contract KIP7All is KIP7Buranble, KIP7Mintable, KIP7 {
  constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply
  ) KIP(name, symbol) {
    _mint(_msgSender(), initialSupply);
  }

}

