// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - a blacklist role that allows to add user to blacklist
 *
 */
contract BlacklistERC20 is AccessControl, ERC20Burnable, ERC20Pausable, ERC20Permit {
    mapping(address => bool) private blacklisted;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BLACKLIST_ROLE = keccak256("BLACKLIST_ROLE");

    event AddedToBlacklist(address account);
    event RemovedFromBlacklist(address account);

    error ZeroAddressCannotBlacklisted();
    error AccountAlreadyBlacklisted();
    error AccountNotBlacklisted();
    error AccountBlacklisted();

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _grantRole(MINTER_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(BLACKLIST_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function addToBlacklist(address account) public onlyRole(BLACKLIST_ROLE) {
        if (account == address(0)) revert ZeroAddressCannotBlacklisted();
        if (blacklisted[account]) revert AccountAlreadyBlacklisted();
        _addToBlacklist(account);
    }

    function removeFromBlacklist(
        address account
    ) public onlyRole(BLACKLIST_ROLE) {
        if (!blacklisted[account]) revert AccountNotBlacklisted();
        _removeFromBlacklist(account);
    }

    function batchBlacklist(
        address[] memory accounts,
        bool toBeBlacklisted
    ) public onlyRole(BLACKLIST_ROLE) {
        for (uint i; i < accounts.length; ++i) {
            toBeBlacklisted
                ? _addToBlacklist(accounts[i])
                : _removeFromBlacklist(accounts[i]);
        }
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted(account);
    }

    function _addToBlacklist(address account) internal {
        blacklisted[account] = true;
        emit AddedToBlacklist(account);
    }

    function _removeFromBlacklist(address account) internal {
        blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    function _isBlacklisted(address account) internal view returns (bool) {
        return blacklisted[account];
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override (ERC20, ERC20Pausable){
        if (isBlacklisted(from)) revert AccountBlacklisted();
        super._update(from, to, value);
    }
}
