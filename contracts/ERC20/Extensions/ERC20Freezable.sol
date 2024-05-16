// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Core/ERC20.sol";

abstract contract ERC20Freezable is ERC20 {
  /**
   * @dev user freezed
   * */
  mapping(address => bool) private freezed;

  /**
   * @dev Emitted when user freezed
   */
  event Freezed(address account);

  /**
   * @dev Emitted when user unfreezed
   */
  event UnFreezed(address account);

  /**
   * @dev  Returns true if account is freezed, and false otherwise.
   *
   * @param account The address
   */
  function isFreezed(address account) public view returns (bool) {
    return freezed[account];
  }

  function _freeze(address account) internal virtual {
    freezed[account] = true;
    emit Freezed(account);
  }

  function _unfreeze(address account) internal virtual {
    freezed[account] = false;
    emit UnFreezed(account);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    require(!freezed[from], "Freezable: from freezed");
    require(!freezed[to], "Freezable: to freezed");
    require(!freezed[_msgSender()], "Freezable: sender freezed");
  }
}
