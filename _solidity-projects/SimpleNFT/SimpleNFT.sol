//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Strings.sol";
import "../utils/Strings.sol";

// Deploy with optimizer set high, 10000 or so
// The higher the optimizer, the less expensive for users to interact with, saving gas
contract SimpleNFT {
    // Map strings for token ids
    using Strings for uint256;

    uint256 constant MAX_SUPPLY = 100;

    // Owner of each token ID
    mapping(uint256 => address) private _owners;

    // Operators for each owner's approvals for managing their NFTs
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operators;

    // Keeping track of all owner balances
    mapping(address => uint256) private _balances;

    string baseURL = "https://example.com/images/";

    // Events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(
            _owners[_tokenId] != address(0),
            "Token ID has not been minted"
        );
        return _owners[_tokenId];
    }

    // Counts all NFTs assigned to an owner
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "cannot query for zero address");
        return _balances[_owner];
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_owners[_tokenId] != address(0), "Token ID does not exist");
        // convert uint256 to string
        string memory id = Strings.toString(_tokenId);
        // encode it packed together
        return string(abi.encodePacked(baseURL, id, ".jpeg"));
    }

    // anyone can mint using whatever token id to use
    function mint(uint256 _tokenId) external {
        require(
            _owners[_tokenId] == address(0),
            "Token ID has already been minted"
        );
        // Token ID should be 0-99
        require(
            _tokenId < MAX_SUPPLY,
            "Token ID is out of bounds, 100 token limit"
        );

        // Bookkeeping
        _owners[_tokenId] = msg.sender;
        _balances[msg.sender] += 1;

        emit Transfer(address(0), msg.sender, _tokenId);
    }

    // Can allow an operator to transfer tokens out on owner's behalf, any token
    function setApprovalForAll(address _operator, bool _approved) external {
        _operators[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Checks if operator is approved for a given owner
    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool) {
        return _operators[_owner][_operator];
    }

    // More granular priviledge for an operator to transfer out THE PROVIDED token ID on the owner's behalf
    // External fn for public access that performs authorization/security checks before calling business logic
    function approve(address _operator, uint256 _tokenId) external payable {
        require(_owners[_tokenId] != address(0), "Token ID does not exist");
        require(
            _owners[_tokenId] == msg.sender ||
                isApprovedForAll(msg.sender, _operator),
            "Only token owner or operator can set approval"
        );
        _approve(_operator, _tokenId);
    }

    // Business logic helper
    function _approve(address _operator, uint256 _tokenId) internal {
        _tokenApprovals[_tokenId] = _operator;
        emit Approval(msg.sender, _operator, _tokenId);
    }

    // simplest way to transfer from one user (wallet) to another
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        require(_owners[_tokenId] != address(0), "Token ID does not exist");
        require(
            _owners[_tokenId] == _from,
            "Only token owner can transfer the token"
        );
        // msg.sender could be the owner or operator
        require(
            _from == msg.sender || _operators[_from][msg.sender],
            "Only owner or operator can transfer the token"
        );
        // reset priviledge for operator after transfer
        _operators[_from][msg.sender] = false;
        // update the on-chain owner
        _owners[_tokenId] = _to;

        // bookkeeping
        _balances[_from] -= 1;
        _balances[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }

    // first checks if recipient is a smart contract (in which case should be able to transfer the NFT from there or it will be stuck/lost)
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        return safeTransferFrom(_from, _to, _tokenId, "");
    }

    // if wanting to send add'l info along with the transfer, can put it in as data argument, usually good for sending to a smart contract
    // Checks that if sending to a contract that it correclty implements the onERC721Received callback signature and reverts if it doesn't
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes data
    ) external payable {}
}
