// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Core/ERC20.sol";

/**
 * @dev  Extension of {ERC20} that allows token to issue
 */
abstract contract ERC20Mintable is ERC20 {
  /**
   * @dev Function to mint tokens
   * @param amount The amount of tokens to mint.
   */
  function mint(uint256 amount) public virtual {
    _mint(_msgSender(), amount);
  }
}
