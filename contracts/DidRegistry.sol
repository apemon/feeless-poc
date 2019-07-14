pragma solidity >0.4.99 <0.6.0;

import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";
import "./IDidRegistry.sol";

contract DidRegistry is IDidRegistry {
    using ECDSA for bytes32;

    struct IDDocument {
        address identity;
        address[] accessors;
        //address[] delegators;
        //uint256 lockedPeriod;
        //uint256 nextActivated;
        bool exist;
    }

    mapping(address => address[]) accessors;
    mapping(address => address[]) delegators;
    mapping(bytes32 => bool) accessorMap;
    mapping(address => bool) exists;
    mapping(address => uint32) nextActivated;
    
    mapping(bytes => bool) signatures;

    mapping(bytes32 => address) proxyNames;

    function () external payable {
        revert("We not accept eth");
    }

    function registerName(string memory _namespace, string memory _identifier, address _address) public {
        bytes32 hash = keccak256(abi.encodePacked(_namespace, _identifier));
        require(proxyNames[hash] == address(0), "id already exist");
        proxyNames[hash] = _address;
        emit RegisterName(_namespace, _identifier, _address);
    }

    function transferName(string memory _namespace, string memory _identifier, address _newAddress) public {
        _transferName(_namespace, _identifier, msg.sender, _newAddress);
    }

    function transferNamePreAuth(string memory _namespace, string memory _identifier, address _newAddress, uint256 _nonce, bytes memory _signature) public {
        require(signatures[_signature] == false, "transaction already complete");
        // check signature
        bytes32 hashedTx = createTransferNamePreAuth(_namespace, _identifier, _newAddress, _nonce);
        hashedTx = hashedTx.toEthSignedMessageHash();
        address from = hashedTx.recover(_signature);
        _transferName(_namespace, _identifier, from, _newAddress);
        signatures[_signature] = true;
    }

    function _transferName(string memory _namespace, string memory _identifier, address _from, address _newAddress) internal {
        bytes32 hash = keccak256(abi.encodePacked(_namespace, _identifier));
        require(proxyNames[hash] != address(0), "id must not zero");
        address owner = proxyNames[hash];
        require(validOwner(owner, _from), "must be valid owner");
        proxyNames[hash] = _newAddress;
        emit TransferName(_namespace, _identifier, owner, _newAddress);
    }

    function createTransferNamePreAuth(string memory _namespace, string memory _identifier, address _newAddress, uint256 _nonce) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_namespace, _identifier, _newAddress, _nonce));
    }

    function resolveName(string memory _namespace, string memory _identifier) public view returns(address) {
        bytes32 hash = keccak256(abi.encodePacked(_namespace, _identifier));
        return proxyNames[hash];
    }

    function getAccessors(address _identity) public view returns(address[] memory) {
        address[] memory _accessors = accessors[_identity];
        return _accessors;
    }

    function addAccessor(address _identity, address _newAccessor) public {
        require(_newAccessor != address(0), "invalid new accessor");
        require(validOwner(_identity, msg.sender), "require valid accessor");
        bool _isExist = exists[_identity];
        if(!_isExist && _newAccessor == _identity) {
            revert("no need to add master key");
        }
        bytes32 hash = keccak256(abi.encodePacked(_identity, _newAccessor));
        if(accessorMap[hash]) revert("already added");
        accessorMap[hash] = true;
        address[] storage _accessors = accessors[_identity];
        _accessors.push(_newAccessor);
        if(!_isExist) {
            _accessors.push(_identity);
            bytes32 masterHash = keccak256(abi.encodePacked(_identity, _identity));
            accessorMap[masterHash] = true;
            exists[_identity] = true;
        }
    }

    function isExist(address _identity) public view returns(bool) {
        return exists[_identity];
    }

    function validOwner(address _identity, address _accessor) public view returns(bool) {
        if(!exists[_identity])
            return _identity == _accessor;
        require(nextActivated[_identity] < block.number, "account must not in freeze period");
        bytes32 hash = keccak256(abi.encodePacked(_identity, _accessor));
        return accessorMap[hash];
    }
}