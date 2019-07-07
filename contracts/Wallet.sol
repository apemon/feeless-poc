pragma solidity >0.4.99 <0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./Ownable.sol";

contract Wallet is Ownable {
    using SafeMath for uint;
    using ECDSA for bytes32;

    mapping(bytes => bool) signatures;

    event Deposit(address indexed from, uint256 amount);
    event Transfer(address indexed to, uint256 amount);

    constructor(address _newOwner) public {
        _transferOwnership(_newOwner);
    }

    function () external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function transfer(address payable _payee, uint256 _amount) public onlyOwner {
        _transfer(_payee, _amount);
    }

    function createPreAuthTransfer(address payable _payee, uint256 _amount, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(_payee, _amount, _fee, _nonce));
        return hash;
    }

    function preAuthTransfer(bytes memory _signature, address payable _payee, uint256 _amount, uint256 _fee, uint256 _nonce) public {
        require(_payee != address(0), "destination address must not zero");
        require(signatures[_signature] == false, "transaction already complete");

        //Create a hash of the transaction details
        bytes32 hashedTx = createPreAuthTransfer(_payee, _amount, _fee, _nonce);
        hashedTx = hashedTx.toEthSignedMessageHash();

        //Obtain the token holder's address and check balance
        address from = hashedTx.recover(_signature);
        require(from == owner(), "invalid signature");
        uint256 total = _amount.add(_fee);
        require(total <= address(this).balance, "balance not enough");

        // Transfer ether
        _transfer(_payee, _amount);
        _transfer(msg.sender, _fee);

        // Mark transaction as completed
        signatures[_signature] = true;
    }

    function transferToken(address _tokenAddr, address payable _payee, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_tokenAddr);
        require(token.balanceOf(address(this)) >= _amount, "not enough token");
        token.transfer(_payee, _amount);
    }

    function createPreAuthTransferToken(address _tokenAddr, address payable _payee, uint256 _amount, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(_tokenAddr, _payee, _amount, _fee, _nonce));
        return hash;
    }

    function preAuthTransferToken(bytes memory _signature, address _tokenAddr, address payable _payee, uint256 _amount, uint256 _fee, uint256 _nonce) public {
        require(_payee != address(0), "destination address must not zero");
        require(signatures[_signature] == false, "transaction already complete");

        //Create a hash of the transaction details
        bytes32 hashedTx = createPreAuthTransferToken(_tokenAddr, _payee, _amount, _fee, _nonce);
        hashedTx = hashedTx.toEthSignedMessageHash();

        //Obtain the token holder's address and check balance
        address from = hashedTx.recover(_signature);
        require(from == owner(), "invalid signature");
        uint256 total = _amount.add(_fee);
        IERC20 token = IERC20(_tokenAddr);
        require(total <= token.balanceOf(from), "balance not enough");

        // Transfer ether
        token.transfer(_payee, _amount);
        token.transfer(msg.sender, _fee);

        // Mark transaction as completed
        signatures[_signature] = true;
    }

    function destroy(address payable recipient) public onlyOwner {
        selfdestruct(recipient);
    }

    function _transfer(address payable _payee, uint256 _amount) internal {
        require(_amount < address(this).balance, "not enough balance");
        _payee.transfer(_amount);
        emit Transfer(_payee, _amount);
    }
}