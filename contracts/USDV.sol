// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BlacklistERC20.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract USDV is BlacklistERC20, ERC2771Recipient {
    uint8 internal _decimals;

    constructor(string memory _name, string memory _symbol, uint _amount, uint8 __decimals, address minter) BlacklistERC20(_name, _symbol) {
        _mint(minter, _amount);
        _decimals = __decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function setTrustedForwarder(address _forwarder) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTrustedForwarder(_forwarder);
    }

    function _msgSender() internal view override(ERC2771Recipient, Context) returns (address ret) {
        return ERC2771Recipient._msgSender();
    }

    function _msgData() internal view override(ERC2771Recipient, Context) returns (bytes calldata ret) {
        return ERC2771Recipient._msgData();
    }

}