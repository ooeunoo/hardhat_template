// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Core/ERC20.sol";

abstract contract ERC20TimeLockable is ERC20 {
  /**
   * @dev Reasons why a user"s tokens have been locked
   */
  mapping(address => bytes32[]) public lockReason;

  /**
   * @dev locked token structure
   */
  struct LockToken {
    uint256 amount;
    uint256 release;
    bool claimed;
  }

  /**
   * @dev Holds number & release of tokens locked for a given reason for
   *      a specified address
   */
  mapping(address => mapping(bytes32 => LockToken)) public locked;

  /**
   * @dev Records data of all the tokens Locked
   */
  event Locked(address indexed account, bytes32 indexed reason, uint256 amount, uint256 release);

  /**
   * @dev Records data of all the tokens unlocked
   */
  event Unlocked(address indexed account, bytes32 indexed reason, uint256 amount);

  /**
   * @dev Locks a specified amount of tokens against an address,
   *      for a specified reason and release
   * @param account Account to be locked
   * @param amount Number of tokens to be locked
   * @param reason The reason to lock tokens
   * @param release Release time in seconds
   */
  function _lock(
    address account,
    uint256 amount,
    bytes32 reason,
    uint256 release
  ) internal virtual returns (bool) {
    // If tokens are already locked, then functions extendLock or
    // increaseLockAmount should be used to make any changes
    require(account != address(0), "TimeLockable: lock account the zero address");
    require(tokensLocked(account, reason) == 0, "TimeLockable: Tokens already locked");
    require(amount != 0, "TimeLockable: Amount can not be zero");
    require(_balances[account] >= amount, "TimeLockable: Not enough amount");

    if (locked[account][reason].amount == 0) lockReason[account].push(reason);

    _transfer(account, address(this), amount);

    locked[account][reason] = LockToken(amount, release, false);

    emit Locked(account, reason, amount, release);
    return true;
  }

  /**
   * @dev Transfers and Locks a specified amount of tokens,
   *      for a specified reason and time
   * @param account adress to which tokens are to be transfered
   * @param amount Number of tokens to be transfered and locked
   * @param reason The reason to lock tokens
   * @param release Release time in seconds
   */
  function _transferWithLock(
    address account,
    uint256 amount,
    bytes32 reason,
    uint256 release
  ) internal virtual returns (bool) {
    require(account != address(0), "TimeLockable: lock account the zero address");
    require(tokensLocked(account, reason) == 0, "TimeLockable: Tokens already locked");
    require(amount != 0, "TimeLockable: Amount can not be zero");
    require(_balances[msg.sender] >= amount, "TimeLockable: Not enough amount");

    _transfer(_msgSender(), account, amount);
    _lock(account, amount, reason, release);
    return true;
  }

  /**
   * @dev Returns tokens locked for a specified address for a
   *      specified reason
   *
   * @param account The address whose tokens are locked
   * @param reason The reason to query the lock tokens for
   */
  function tokensLocked(address account, bytes32 reason) public view returns (uint256 amount) {
    if (!locked[account][reason].claimed) amount = locked[account][reason].amount;
  }

  /**
   * @dev Returns tokens locked for a specified address for a
   *      specified reason at a specific time
   *
   * @param account The address whose tokens are locked
   * @param reason The reason to query the lock tokens for
   * @param time The timestamp to query the lock tokens for
   */
  function tokensLockedAtTime(
    address account,
    bytes32 reason,
    uint256 time
  ) public view returns (uint256 amount) {
    if (locked[account][reason].release > time) amount = locked[account][reason].amount;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    uint256 unlockableAmount = getUnlockableTokens(account);
    return super.balanceOf(account) + unlockableAmount;
  }

  /**
   * @dev Returns total tokens held by an address (locked + transferable)
   * @param account The address to query the total balance of
   */
  function totalBalanceOf(address account) public view returns (uint256 amount) {
    amount = balanceOf(account);

    for (uint256 i = 0; i < lockReason[account].length; i++) {
      amount = amount + tokensLocked(account, lockReason[account][i]);
    }
  }

  /**
   * @dev Extends lock for a specified reason and time
   * @param account The account which lock release will increase
   * @param reason The reason to lock tokens
   * @param time Lock extension release time in seconds
   */
  function _extendLock(
    address account,
    bytes32 reason,
    uint256 time
  ) internal virtual returns (bool) {
    require(tokensLocked(account, reason) > 0, "TimeLockable: No tokens locked");

    locked[account][reason].release = locked[account][reason].release + time;

    emit Locked(account, reason, locked[account][reason].amount, locked[account][reason].release);
    return true;
  }

  /**
   * @dev Increase number of tokens locked for a specified reason
   * @param account The account which lock amount will increase
   * @param reason The reason to lock tokens
   * @param amount Number of tokens to be increased
   */
  function _increaseLockAmount(
    address account,
    bytes32 reason,
    uint256 amount
  ) internal virtual returns (bool) {
    require(tokensLocked(account, reason) > 0, "TimeLockable: No tokens locked");
    require(amount != 0, "TimeLockable: Amount can not be zero");
    require(_balances[account] >= amount, "TimeLockable: Not enough amount");

    _transfer(account, address(this), amount);

    locked[account][reason].amount = locked[account][reason].amount + amount;

    emit Locked(account, reason, locked[account][reason].amount, locked[account][reason].release);
    return true;
  }

  /**
   * @dev Returns unlockable tokens for a specified address for a specified reason
   * @param account The address to query the the unlockable token count of
   * @param reason The reason to query the unlockable tokens for
   */
  function tokensUnlockable(address account, bytes32 reason) public view returns (uint256 amount) {
    if (locked[account][reason].release <= block.timestamp && !locked[account][reason].claimed)
      //solhint-disable-line
      amount = locked[account][reason].amount;
  }

  /**
   * @dev Unlocks the unlockable tokens of a specified address
   * @param account Address of user, claiming back unlockable tokens
   */
  function _unlock(address account) internal virtual returns (uint256 unlockableTokens) {
    uint256 lockedTokens;

    for (uint256 i = 0; i < lockReason[account].length; i++) {
      lockedTokens = tokensUnlockable(account, lockReason[account][i]);
      if (lockedTokens > 0) {
        unlockableTokens = unlockableTokens + lockedTokens;
        locked[account][lockReason[account][i]].claimed = true;
        emit Unlocked(account, lockReason[account][i], lockedTokens);
      }
    }

    if (unlockableTokens > 0) this.transfer(account, unlockableTokens);
  }

  /**
   * @dev Gets the unlockable tokens of a specified address
   * @param account The address to query the the unlockable token count of
   */
  function getUnlockableTokens(address account) public view returns (uint256 unlockableTokens) {
    for (uint256 i = 0; i < lockReason[account].length; i++) {
      unlockableTokens = unlockableTokens + (tokensUnlockable(account, lockReason[account][i]));
    }
  }

  /**
   * @dev See {ERC20-_beforeTokenTransfer}.
   *
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    _unlock(from);
  }
}
