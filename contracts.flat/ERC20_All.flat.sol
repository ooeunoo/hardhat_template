// Sources flattened with hardhat v2.1.2 https://hardhat.org

// File contracts/ERC20/Interface/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File contracts/ERC20/Interface/IERC20Metadata.sol

// SPDX-License-Identifier: MIT

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
  /**
   * @dev Returns the name of the token.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function decimals() external view returns (uint8);
}

// File contracts/Utils/Context.sol

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File contracts/ERC20/Core/ERC20.sol

// SPDX-License-Identifier: MIT

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) internal _balances;

  mapping(address => mapping(address => uint256)) internal _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  /**
   * @dev Sets the values for {name} and {symbol}.
   *
   * The defaut value of {decimals} is 18. To select a different value for
   * {decimals} you should overload it.
   *
   * All two of these values are immutable: they can only be set once during
   * construction.
   */
  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5,05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the value {ERC20} uses, unless this function is
   * overridden;
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20}.
   *
   * Requirements:
   *
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for ``sender``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    _approve(sender, _msgSender(), currentAllowance - amount);

    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);

    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    _balances[sender] = senderBalance - amount;
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    _balances[account] = accountBalance - amount;
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
   *
   * This internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be to transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

// File contracts/ERC20/Extensions/ERC20Ownable.sol

// SPDX-License-Identifier: MIT

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract ERC20Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File contracts/ERC20/Extensions/ERC20Pausable.sol

// SPDX-License-Identifier: MIT

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20 {
  /**
   * @dev Emitted when the pause is triggered by `account`.
   */
  event Paused(address account);

  /**
   * @dev Emitted when the pause is lifted by `account`.
   */
  event Unpaused(address account);

  bool private _paused;

  /**
   * @dev Initializes the contract in unpaused state.
   */
  constructor() {
    _paused = false;
  }

  /**
   * @dev Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view virtual returns (bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  /**
   * @dev Triggers stopped state.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Returns to normal state.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }

  /**
   * @dev See {ERC20-_beforeTokenTransfer}.
   *
   * Requirements:
   *
   * - the contract must not be paused.
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    require(!paused(), "ERC20Pausable: token transfer while paused");
  }
}

// File contracts/ERC20/Extensions/ERC20Freezable.sol

// SPDX-License-Identifier: MIT

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

// File contracts/ERC20/Extensions/ERC20TimeLockable.sol

// SPDX-License-Identifier: MIT

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

// File contracts/ERC20/Extensions/ERC20Mintable.sol

// SPDX-License-Identifier: MIT

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

// File contracts/ERC20/Extensions/ERC20Burnable.sol

// SPDX-License-Identifier: MIT

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is ERC20 {
  /**
   * @dev Destroys `amount` tokens from the caller.
   *
   * See {ERC20-_burn}.
   */
  function burn(uint256 amount) public virtual {
    _burn(_msgSender(), amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, deducting from the caller's
   * allowance.
   *
   * See {ERC20-_burn} and {ERC20-allowance}.
   *
   * Requirements:
   *
   * - the caller must have allowance for ``accounts``'s tokens of at least
   * `amount`.
   */
  function burnFrom(address account, uint256 amount) public virtual {
    uint256 currentAllowance = allowance(account, _msgSender());
    require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
    _approve(account, _msgSender(), currentAllowance - amount);
    _burn(account, amount);
  }
}

// File contracts/ERC20/Templates/ERC20_All.sol

// SPDX-License-Identifier: MIT

contract ERC20All is ERC20Ownable, ERC20Mintable, ERC20Burnable, ERC20Pausable, ERC20Freezable, ERC20TimeLockable {
  constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply
  ) ERC20(name, symbol) {
    _mint(_msgSender(), initialSupply);
  }

  function mint(uint256 amount) public override(ERC20Mintable) onlyOwner {
    super.mint(amount);
  }

  function balanceOf(address account) public view override(ERC20, ERC20TimeLockable) returns (uint256) {
    return super.balanceOf(account);
  }

  /* 토큰 동결 */
  function pause() public onlyOwner {
    _pause();
  }

  /* 토큰 동결 해제 */
  function unpause() public onlyOwner {
    _unpause();
  }

  /* 주소 동결 */
  function freeze(address account) public onlyOwner {
    _freeze(account);
  }

  /* 주소 동결 해제 */
  function unfreeze(address account) public onlyOwner {
    _unfreeze(account);
  }

  /* 락업 */
  function lock(
    address account,
    uint256 amount,
    bytes32 reason,
    uint256 release
  ) public onlyOwner {
    _lock(account, amount, reason, release);
  }

  /* 락업 토큰 전송 */
  function transferWithLock(
    address account,
    uint256 amount,
    bytes32 reason,
    uint256 release
  ) public onlyOwner {
    _transferWithLock(account, amount, reason, release);
  }

  /* 락업 기간 연장 */
  function extendLock(
    address account,
    bytes32 reason,
    uint256 time
  ) public onlyOwner {
    _extendLock(account, reason, time);
  }

  /* 락업 수량 증액 */
  function increaseLockAmount(
    address account,
    bytes32 reason,
    uint256 amount
  ) public onlyOwner {
    _increaseLockAmount(account, reason, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override(ERC20, ERC20Pausable, ERC20Freezable, ERC20TimeLockable) {
    super._beforeTokenTransfer(from, to, amount);
  }
}
