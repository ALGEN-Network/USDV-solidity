// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BlacklistERC20Upgradeable.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract USDVUpgradeable is BlacklistERC20Upgradeable, ERC2771Recipient {
    uint8 internal _decimals;

    function initialize(string memory _name, string memory _symbol, uint _amount, uint8 __decimals, address minter) public initializer {
        __BlacklistERC20_init(_name, _symbol);
        _mint(minter, _amount);
        _decimals = __decimals;
    }


    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function setTrustedForwarder(address _forwarder) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTrustedForwarder(_forwarder);
    }

    function _msgSender() internal view override(ERC2771Recipient, ContextUpgradeable) returns (address ret) {
        return ERC2771Recipient._msgSender();
    }

    function _msgData() internal view override(ERC2771Recipient, ContextUpgradeable) returns (bytes calldata ret) {
        return ERC2771Recipient._msgData();
    }

}