// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title A sample Raffle contract
 * @author Neeraj Singh
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRF2
 */
contract Raffle {
    error Raffle__NotEnoughEthSent();

    /** State variables */
    uint256 private constant REQUEST_CONFIRMATIONS = 3;
    uint256 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    address private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimt;

    address payable[] private s_players;
    uint256 private s_lastTimestamp;

    /** Events */

    event EnteredRaffle(address indexed player);

    constructor(
        uint256 _entraceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit,
        uint256 _numWords
    ) {
        i_entranceFee = _entraceFee;
        i_interval = _interval;
        i_vrfCoordinator = _vrfCoordinator;
        i_keyHash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimt = _callbackGasLimit;
        s_lastTimestamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();
        // 1. Makes migration easier
        // 2. Makes frontend "indexing" easier
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }

    // 1. Get a random number
    // 2. Use the random number to pick a player
    // 3. Be automatically called
    function pickWinner() public {
        // check to see if enough time has passed
        if ((block.timestamp - s_lastTimestamp) < i_interval) revert();

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, // gas lane
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimt,
            NUM_WORDS
        );
    }

    /** Getter Function */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
