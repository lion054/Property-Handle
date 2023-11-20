pragma solidity ^0.8.4;

// SPDX-License-Identifier: UNLICENSED

import "./Ownable.sol"; //Added for extended management of the contract

//Define the safe math library (taken from Open Zeppelin)
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Payout {
    using SafeMath for uint256;

    //VARIABLES
    uint256 internal amountForCalc1 = 0;
    uint256 internal amountForCalc2;
    uint256 internal _percentageSum = 0;
    uint256 _totalRecipients = 0;

    //MAPPING (manages the users and their shares)
    mapping(uint256 => address) public recipients;
    mapping(address => uint256) public shares;

    //It was decided to currently not use a fallback payment function

    //FUNCTIONS
    function fundContract() public payable {
        require(msg.value > 0, "Royalty amount must be higher than 0");
        amountForCalc1 = amountForCalc1.add(msg.value);
    }

    function addRecipient(uint256 _percentage, address _address)
        public
        returns (bool success)
    {
        //Make sure that the added recipient doesn't hurt the integrity of the data constraint
        require(
            _percentage > 0 &&
                _percentage <= 100 &&
                (_percentageSum + _percentage) <= 100,
            "Percentages are not valid"
        );

        //Update the data in the mappings and update the index
        recipients[_totalRecipients] = _address;
        shares[_address] = _percentage;
        _totalRecipients++;

        //Update the total percentage monitoring
        _percentageSum = _percentageSum.add(_percentage);

        return true;
    }

    function payRecipients() public payable returns (bool success) {
        //Validate that funds have been deposited in the contract
        require(amountForCalc1 > 0, "No funds have been sent to the contract");
        //Validate that the trasnfer of funds will only be done after 100% of recipients have been updated in the mappings
        if (_percentageSum != 100) {
            return false;
        } else {
            //Clean up variable
            _percentageSum = 0;
            //Perform step 1 of percentage caluclation
            amountForCalc2 = amountForCalc1.div(100);
            //Clean up variable
            amountForCalc1 = 0;
                // Go over each mapping item and transfer the relative percentage of funds to its supplied address
                for (uint256 i = 0; i < _totalRecipients; i++) {
                    address payable recipient = payable(recipients[i]);
                    recipient.transfer(amountForCalc2.mul(shares[recipient]));

                    // Clean up mappings
                    delete recipients[i];
                    delete shares[recipient];
                }
            return true;
        }
    }
}