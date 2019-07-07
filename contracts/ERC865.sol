pragma solidity >=0.4.21 <0.6.0;

import "./IERC865.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

contract ERC865 is IERC865, ERC20 {
    using SafeMath for uint;
    using ECDSA for bytes32;

    mapping(bytes => bool) signatures;

    /**
     * @dev Allows a delegate to submit a transaction on behalf of the token holder.
     * @param _signature The signature, issued by the token holder.
     * @param _to The recipient's address.
     * @param _value The amount of tokens to be transferred.
     * @param _fee The amount of tokens paid to the delegate for gas costs.
     * @param _nonce The transaction number.
     */
    function transferPreSigned(
        bytes memory _signature,
        address payable _from,
        address payable _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    ) public returns (bool) {
        require(_to != address(0), "destination address must not zero");
        require(signatures[_signature] == false, "transaction already complete");

        //Create a hash of the transaction details
        bytes32 hashedTx = _transferPreSignedHashing(_to, _value, _fee, _nonce);
        hashedTx = hashedTx.toEthSignedMessageHash();

        //Obtain the token holder's address and check balance
        address from = hashedTx.recover(_signature);
        require(from == _from, "invalid signature");
        uint256 total = _value.add(_fee);
        require(total <= balanceOf(from), "balance not enough");

        // Transfer tokens
        _transfer(from, _to, _value);
        _transfer(from, msg.sender, _fee);

        // Mark transaction as completed
        signatures[_signature] = true;

        //TransferPreSigned ERC865 events
        emit TransferPreSigned(msg.sender, from, _to, _value);
        emit TransferPreSigned(msg.sender, from, msg.sender, _fee);

        return true;
    }

    /**
     * @dev Creates a hash of the transaction information passed to transferPresigned.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     * @return A copy of the hashed message signed by the token holder, with prefix added.
     */
    function _transferPreSignedHashing(
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        internal pure
        returns (bytes32)
    {
        //Create a copy of thehashed message signed by the token holder
        bytes32 hash = keccak256(abi.encodePacked(_to, _value, _fee, _nonce));

        //Add prefix to hash
        return hash;
    }

    function createTransferHashing(
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public pure
        returns (bytes32) 
    {
        return _transferPreSignedHashing(_to, _value, _fee, _nonce);
    }

    function testRecover(
        bytes32 hash,
        bytes memory signature
    ) 
    public pure
    returns (address) {
        return hash.recover(signature);
    }

    function testHash(
        bytes memory _text
    )
    public pure
    returns (bytes32)
    {
        //Create a copy of thehashed message signed by the token holder
        bytes32 hash = keccak256(abi.encodePacked(_text));

        //Add prefix to hash
        return hash;
    }

    
}