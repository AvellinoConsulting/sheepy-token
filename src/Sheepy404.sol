// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SheepyBase} from "./SheepyBase.sol";
import {DN404} from "dn404/src/DN404.sol";
import {LibString} from "solady/utils/LibString.sol";
import {LibBitmap} from "solady/utils/LibBitmap.sol";
import {DynamicArrayLib} from "solady/utils/DynamicArrayLib.sol";

/// @dev This contract can be used by itself or as an proxy's implementation.
contract Sheepy404 is DN404, SheepyBase {
    using LibBitmap for *;
    using DynamicArrayLib for *;

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           ERRORS                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    // Error for URI already assigned
    error URIAlreadyAssigned();
    // Error for token not revealed
    error TokenNotRevealed();
    // Error for token ID already revealed
    error TokenIdAlreadyRevealed(uint256 tokenId);

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           EVENTS                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Emitted when `tokenIds` is revealed.
    event RevealBatch(uint256[] indexed tokenIds, uint256[] indexed uriIds);

    /// @dev Emitted when `tokenId` is transferred and the metadata should be reset.
    event Reset(uint256 indexed tokenId);

    /// @dev Emitted when `tokenIds` is rerolled.
    event RerollBatch(uint256[] indexed tokenIds, uint256[] indexed uriIds);

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                          STORAGE                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev The name of the contract.
    string internal _name;

    /// @dev The symbol of the contract.
    string internal _symbol;

    /// @dev The base URI of the contract.
    string internal _baseURI;

    /// @dev Whether a certain `tokenId` has been revealed.
    LibBitmap.Bitmap internal _revealed;

    /// @dev How much native currency required to reveal a token.
    uint256 public revealPrice;

    /// @dev The address of the fee collector.
    address public feeCollector;

    /// @dev How much native currency required to reroll a token.
    uint256 public rerollPrice;

    // Mapping from token ID to URI ID
    mapping(uint256 => uint256) private _tokenURIs;

    // Mapping to track assigned URI IDs
    mapping(uint256 => bool) private _assignedURIs;

    // Mapping to track reroll count for each token ID
    mapping(uint256 => uint256) private _rerollCounts;

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                        INITIALIZER                         */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev For initialization.
    function initialize(
        address initialOwner,
        address initialAdmin,
        address mirror,
        string memory notSoSecret
    ) public virtual {
        uint256 initialSupply = 1_000_000_000 * 10 ** 18;
        _initializeSheepyBase(initialOwner, initialAdmin, notSoSecret);
        _initializeDN404(initialSupply, initialOwner, mirror);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                          METADATA                          */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the name.
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /// @dev Returns the symbol.
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // Function to set the URI ID for a token ID
    function _setTokenURI(uint256 tokenId, uint256 uriId) internal virtual {
        if (!_exists(tokenId)) revert TokenDoesNotExist();
        if (_assignedURIs[uriId]) revert URIAlreadyAssigned();
        _tokenURIs[tokenId] = uriId;
        _assignedURIs[uriId] = true;
    }

    // Function to check if a URI ID is already assigned
    function isURIIdAssigned(uint256 uriId) public view returns (bool) {
        return _assignedURIs[uriId];
    }

    /// @dev Returns the default mode for the skip NFT status.
    function _skipNFTDefault() internal pure override returns (SkipNFTDefault) {
        return SkipNFTDefault.Off;
    }

    /**
    * @dev Calculates the total reroll cost for an array of token IDs.
    * @param tokenIds An array of token IDs for which to calculate the reroll cost.
    * @return totalCost The total cost required to reroll the given token IDs.
    */
    function calculateRerollCost(uint256[] calldata tokenIds) public view returns (uint256 totalCost) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 rerollCount = _rerollCounts[tokenId];
            uint256 costMultiplier = rerollCount < 2 ? rerollCount + 1 : 3;
            totalCost += rerollPrice * costMultiplier;
        }
    }

    /// @dev Returns the token URI.
    function _tokenURI(uint256 tokenId) internal view virtual override returns (string memory result) {
        if (!_exists(tokenId)) revert TokenDoesNotExist();
        string memory baseURI = _baseURI;
        uint256 uriId = _tokenURIs[tokenId];
        if (bytes(baseURI).length != 0) {
            if (uriId == 0) {
                result = "";
            } else {
                result = LibString.replace(baseURI, "{id}", LibString.toString(uriId));
            }
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           REVEAL                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /**
    * @notice Reveals the URIs for a batch of tokens.
    * @dev This function allows the caller to reveal the URIs for multiple tokens in a single transaction.
    * It checks for various conditions such as token existence, authorization, and sufficient balance before proceeding.
    * The function also ensures that the state is updated before any external calls are made.
    * @param tokenIds An array of token IDs to be revealed.
    * @param uriIds An array of URI IDs corresponding to the token IDs.
    * @dev Requirements:
    * - `tokenIds` and `uriIds` must have the same length.
    * - `tokenIds` array must not be empty.
    * - Each token ID must not have been revealed already.
    * - Caller must have sufficient balance to cover the total cost of revealing the tokens.
    * - Caller must be authorized to reveal each token ID.
    * - Each URI ID must not be already assigned.
    * - Each token ID must exist.
    * @dev Emits:
    * - A {RevealBatch} event upon successful execution.
    */
    function reveal(uint256[] calldata tokenIds, uint256[] calldata uriIds) external virtual {
        require(tokenIds.length > 0, "Token IDs array is empty.");
        require(tokenIds.length == uriIds.length, "Mismatched input lengths.");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (_revealed.get(tokenId)) revert TokenIdAlreadyRevealed(tokenId);

            uint256 uriId = uriIds[i];

            if (!_callerIsAuthorizedFor(tokenId)) revert Unauthorized();
            if (isURIIdAssigned(uriId)) revert URIAlreadyAssigned();
            if (!_exists(tokenId)) revert TokenDoesNotExist();

            _setTokenURI(tokenId, uriId);
            _revealed.set(tokenId);
        }

        emit RevealBatch(tokenIds, uriIds);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           REROLL                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /**
    * @dev Allows the owner of the NFTs to pay to reroll the `tokenIds` and `uriIds`.
    * @notice This function enables the caller to reroll the URIs of multiple tokens.
    * @param tokenIds An array of token IDs to reroll.
    * @param uriIds An array of new URI IDs to assign to the tokens.
    * @dev Requirements:
    * - The `tokenIds` array must not be empty.
    * - The lengths of `tokenIds` and `uriIds` arrays must match.
    * - The caller must have a sufficient balance to cover the total reroll cost.
    * - Each token ID must exist.
    * - The caller must be authorized to modify each token ID.
    * - Each new URI ID must not already be assigned.
    * - Each token ID must have been revealed (i.e., have an assigned URI).
    * @dev Effects:
    * - Updates the URI of each token ID and increments its reroll count.
    * - Transfers the total reroll cost to the fee collector.
    * @dev Emits:
    * - `RerollBatch` event when the URIs of multiple tokens are successfully rerolled.
    */
    function reroll(uint256[] calldata tokenIds, uint256[] calldata uriIds) external virtual {
        require(tokenIds.length > 0, "Token IDs array is empty.");
        require(tokenIds.length == uriIds.length, "Mismatched input lengths.");

        uint256 totalCost = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 rerollCount = _rerollCounts[tokenId];
            uint256 costMultiplier = rerollCount < 2 ? rerollCount + 1 : 3;
            totalCost += rerollPrice * costMultiplier;
        }

        uint256 userBalance = balanceOf(msg.sender);
        uint256 numOfOwnedTokens = _balanceOfNFT(msg.sender);
        uint256 tokensNeededToRetainNFT = numOfOwnedTokens * _unit();
        require((userBalance - tokensNeededToRetainNFT) >= totalCost, "Insufficient balance.");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 uriId = uriIds[i];

            if (!_exists(tokenId)) revert TokenDoesNotExist();
            if (!_callerIsAuthorizedFor(tokenId)) revert Unauthorized();
            if (isURIIdAssigned(uriId)) revert URIAlreadyAssigned();
            if (!isURIIdAssigned(_tokenURIs[tokenId])) revert TokenNotRevealed();

            uint256 previousUriId = _tokenURIs[tokenId];
            _assignedURIs[previousUriId] = false;

            _setTokenURI(tokenId, uriId);
            _rerollCounts[tokenId] += 1;
        }

        transfer(feeCollector, totalCost);

        emit RerollBatch(tokenIds, uriIds);
    }

    /// @dev Returns if each of the `tokenIds` has been revealed.
    function revealed(uint256[] memory tokenIds) public view returns (bool[] memory) {
        uint256[] memory results = DynamicArrayLib.malloc(tokenIds.length);
        for (uint256 i; i < tokenIds.length; ++i) {
            results.set(i, _revealed.get(tokenIds.get(i)));
        }
        return results.asBoolArray();
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                   PUBLIC VIEW FUNCTIONS                    */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Return all the NFT token IDs owned by `owner`.
    function ownedIds(address owner) public view returns (uint256[] memory) {
        return _ownedIds(owner, 0, type(uint256).max);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                      ADMIN FUNCTIONS                       */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Sets the name and symbol.
    function setNameAndSymbol(string memory newName, string memory newSymbol)
        public
        virtual
        onlyOwnerOrRole(ADMIN_ROLE)
    {
        _name = newName;
        _symbol = newSymbol;
    }

    /// @dev Sets the base URI.
    function setBaseURI(string memory newBaseURI) public virtual onlyOwnerOrRole(ADMIN_ROLE) {
        _baseURI = newBaseURI;
    }

    /// @dev Sets the reveal price.
    function setRevealPrice(uint256 newRevealPrice) public onlyOwnerOrRole(ADMIN_ROLE) {
        revealPrice = newRevealPrice;
    }

    /// @dev Sets the reroll price.
    function setRerollPrice(uint256 newRerollPrice) public onlyOwnerOrRole(ADMIN_ROLE) {
        rerollPrice = newRerollPrice;
    }

    /// @dev Sets the fee collector.
    function setFeeCollector(address newFeeCollector) public onlyOwnerOrRole(ADMIN_ROLE) {
        feeCollector = newFeeCollector;
    }
    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                      INTERNAL HELPERS                      */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns if `msg.sender` can reveal `id`.
    function _callerIsAuthorizedFor(uint256 id) internal view returns (bool) {
        // `_ownerOf` will revert if the token does not exist.
        address nftOwner = _ownerOf(id);
        if (nftOwner == msg.sender) return true;
        if (_isApprovedForAll(nftOwner, msg.sender)) return true;
        if (_getApproved(id) == msg.sender) return true;
        return false;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                         OVERRIDES                          */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev 100k full ERC20 tokens for 1 ERC721 NFT.
    function _unit() internal view virtual override returns (uint256) {
        return 100_000 * 10 ** 18;
    }

    /// @dev Hook that is called after a batch of NFT transfers.
    /// The lengths of `from`, `to`, and `ids` are guaranteed to be the same.
    function _afterNFTTransfers(address[] memory from, address[] memory to, uint256[] memory ids)
        internal
        virtual
        override
    {
        // Emit a {Reset} event for each id if the caller isn't the mirror.
        if (msg.sender != _getDN404Storage().mirrorERC721) {
            for (uint256 i; i < ids.length; ++i) {
                uint256 id = ids.get(i);
                if (from.toUint256Array().get(i) != to.toUint256Array().get(i)) {
                    _revealed.unset(id);
                    emit Reset(id);
                }

                if (to.toUint256Array().get(i) == 0) {
                    uint256 uriId = _tokenURIs[id];
                    _assignedURIs[uriId] = false;
                    delete _tokenURIs[id];
                }
            }
        }
    }

    /// @dev Need to override this.
    function _useAfterNFTTransfers() internal virtual override returns (bool) {
        return true;
    }
}