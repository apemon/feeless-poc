pragma solidity >=0.4.21 <0.6.0;

interface IDidRegistry {
    function registerName(
        string calldata _namespace,
        string calldata _identifier,
        address _address
    ) external;

    function transferName(
        string calldata _namespace,
        string calldata _identifier,
        address _newAddress
    ) external;

    function resolveName(
        string calldata _namespace,
        string calldata _identifier
    ) external view returns(address);

    function transferNamePreAuth(
        string calldata _namespace,
        string calldata _identifier,
        address _newAddress,
        uint256 _nonce,
        bytes calldata _signature
    ) external;

    function validOwner(
        address _identity,
        address _owner
    ) external view returns (bool);

    event RegisterName(
        string namespace,
        string identifier,
        address indexed newAddress);

    event TransferName(
        string namespace,
        string identifier,
        address indexed oldAddress,
        address indexed newAddress
    );
}