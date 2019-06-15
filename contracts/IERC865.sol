pragma solidity >=0.4.21 <0.6.0;

interface IERC865 {
    function transferPreSigned(
        bytes calldata _signature,
        address payable _from,
        address payable _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    ) external returns (bool);

    event TransferPreSigned(
        address indexed delegate,
        address indexed from,
        address indexed to,
        uint256 value
    );
}