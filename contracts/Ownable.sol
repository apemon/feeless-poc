pragma solidity >=0.4.21 <0.6.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }
    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function _transferOwnership(address _newOwner) internal {
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}