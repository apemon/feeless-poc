pragma solidity >=0.4.21 <0.6.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract JunkCoin is Ownable, ERC20, ERC20Detailed {

    using SafeMath for uint;

    event Mint(address indexed to, uint amount);

    constructor (string memory _name, string memory _symbol, uint8 _decimal)
        ERC20Detailed(_name, _symbol, _decimal) public {
        
    }

    function buyToken() public payable {
        _mint(msg.sender, 1);
    }
}