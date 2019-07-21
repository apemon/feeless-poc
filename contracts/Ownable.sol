pragma solidity >=0.4.21 <0.6.0;

import "./IDidRegistry.sol";

contract Ownable {
    address private _owner;
    address private _registry;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    function registry() public view returns (address) {
        return _registry;
    }

    function _setRegistryAddress(address _newRegistry) internal {
        _registry = _newRegistry;
    }

    function isOwner(address _actor) public view returns (bool) {
        if(_registry == address(0))
            return _actor == _owner;
        IDidRegistry did = IDidRegistry(_registry);
        return did.validOwner(_owner, _actor);
    }

    modifier onlyOwner(address _actor) {
        require(isOwner(_actor), "Ownable: caller is not the owner");
        _;
    }

    function _transferOwnership(address _newOwner) internal {
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}