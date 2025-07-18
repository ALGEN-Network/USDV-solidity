// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BlacklistERC20Upgradeable.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IOptimismMintableERC20 is IERC165 {
    function remoteToken() external view returns (address);

    function bridge() external returns (address);

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

interface ILegacyMintableERC20 is IERC165 {
    function l1Token() external view returns (address);

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract USDVUpgradeableV2 is BlacklistERC20Upgradeable, ERC2771Recipient, ISemver {
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

    /// @notice Semantic version.
    /// @custom:semver 1.3.0
    string public constant version = "1.3.0";

    /// @notice Address of the corresponding version of this token on the remote chain.
    address public REMOTE_TOKEN;

    /// @notice Address of the StandardBridge on this network.
    address public BRIDGE;

    /// @notice Emitted whenever tokens are minted for an account.
    /// @param account Address of the account tokens are being minted for.
    /// @param amount  Amount of tokens minted.
    event Mint(address indexed account, uint256 amount);

    /// @notice Emitted whenever tokens are burned from an account.
    /// @param account Address of the account tokens are being burned from.
    /// @param amount  Amount of tokens burned.
    event Burn(address indexed account, uint256 amount);

    /// @notice A modifier that only allows the bridge to call
    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "OptimismMintableERC20: only bridge can mint and burn");
        _;
    }

    function setL1Token(
        address _bridge,
        address _remoteToken
    ) public onlyRole(MINTER_ROLE){
        REMOTE_TOKEN = _remoteToken;
        BRIDGE = _bridge;
    }

    /// @notice Allows the StandardBridge on this network to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function mint(
        address _to,
        uint256 _amount
    )
        public
        virtual
        override(BlacklistERC20Upgradeable)
        onlyBridge
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    /// @notice Allows the StandardBridge on this network to burn tokens.
    /// @param _from   Address to burn tokens from.
    /// @param _amount Amount of tokens to burn.
    function burn(
        address _from,
        uint256 _amount
    )
        public
        virtual
        onlyBridge
    {
        _burn(_from, _amount);
        emit Burn(_from, _amount);
    }

    function supportsInterface(bytes4 _interfaceId) public pure virtual override(AccessControlUpgradeable) returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        // Interface corresponding to the legacy L2StandardERC20.
        bytes4 iface2 = type(ILegacyMintableERC20).interfaceId;
        // Interface corresponding to the updated OptimismMintableERC20 (this contract).
        bytes4 iface3 = type(IOptimismMintableERC20).interfaceId;
        return _interfaceId == iface1 || _interfaceId == iface2 || _interfaceId == iface3;
    }

    /// @custom:legacy
    /// @notice Legacy getter for the remote token. Use REMOTE_TOKEN going forward.
    function l1Token() public view returns (address) {
        return REMOTE_TOKEN;
    }

    /// @custom:legacy
    /// @notice Legacy getter for the bridge. Use BRIDGE going forward.
    function l2Bridge() public view returns (address) {
        return BRIDGE;
    }

    /// @custom:legacy
    /// @notice Legacy getter for REMOTE_TOKEN.
    function remoteToken() public view returns (address) {
        return REMOTE_TOKEN;
    }

    /// @custom:legacy
    /// @notice Legacy getter for BRIDGE.
    function bridge() public view returns (address) {
        return BRIDGE;
    }

}