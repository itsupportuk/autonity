pragma solidity ^0.4.23;

/* Soma.sol
*
*  Soma is a smart contract implementation of Clique consensus, see EIP 225,
*  however validators no longer vote for proposers to be added or removed through the Soma contract.
*/

// import "./SomaInterface.sol";

contract Soma  {
    mapping (address => bool) public m_validators;
    mapping (address => bool) public m_recent_validators;
    mapping (address => uint256) public m_votes;

    address[] public validators;
    uint256 public threshold;

    /*
    * constructor
    *
    * Initialises the initial validator set to the Soma contract
    * param: _validators (address[]) array containing the addresses of initial validator set
    */
    constructor (address[] _validators) public {
        // Append validators and vote threshold
        for (uint256 i = 0; i < _validators.length; i++) {
            m_validators[_validators[i]] = true;
            validators.push(_validators[i]);
        }

        // Calculate threshold
        threshold = (validators.length / 2) + 1;
    }

/*
========================================================================================================================

    Functions

========================================================================================================================
*/

    /*
    * CastVote
    *
    * Interface for users to cast their votes to propose addition or removal of a validator from the set
    * param: _vote (address) the address to be added or removed from the validator set
    */
    function castVote(address _vote) public onlyActiveValidators(msg.sender) {
        // Increment vote
        m_votes[_vote]++;

        if (m_votes[_vote] >= threshold) {
            updateValidators(_vote);
        }
    }

    /*
    * updateValidators
    *
    * Internal function to add and remove validators from the set when threshold is passed
    * params: _vote (address) the address to be added or removed from the validator set
    */
    function updateValidators(address _vote) private {
        // If validator already exists remove
        if(m_validators[_vote]) {
            m_validators[_vote] = false;
            for (uint256 i = 0; i < validators.length; i++) {
                if (_vote==validators[i]) {
                    delete validators[i];
                }
            }
        } else {
            m_validators[_vote] = true;
            validators.push(_vote);
        }

        // Reset vote count
        m_votes[_vote] = 0;

        // Recalculate threshold
        threshold = (validators.length / 2) + 1;        

    }

    /*
    * ActiveValidator
    *
    * Returns boolean to indicate whether a given address is in the validator set
    */
    function ActiveValidator(address _validator) public view returns (bool) {
        return m_validators[_validator];
    }


/*
========================================================================================================================

    Modifiers

========================================================================================================================
*/

    /*
    * onlyActiveValidators
    *
    * Modifier that checks if the voter is an active validator
    */
    modifier onlyActiveValidators(address _voter) {
        require(m_validators[_voter], "Voter is not active validator");
        _;
    }


}