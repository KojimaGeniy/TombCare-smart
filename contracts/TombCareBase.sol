pragma solidity ^0.4.23;
import "./TombCareAccessControl.sol";
import "./utils/SafeMath.sol";

contract TombCareBase is TombCareAccessControl{
    using SafeMath for uint256;


    //--STORAGE--//
    enum ServiceStatus { 
        NewOrder, 
        AssignProvider, //it's about accepting job
        CompleteJob, 
        ClaimResolution, 
        TransactionExecuted 
    }

    struct CareObject {
        address miner;
        uint16 typeObj;
        uint16 status;
        string dataHash;
    }

    struct Service {
        uint256 careObjectId;
        uint16 serviceTypeId;
        address provider;
        uint256 priceUsd;
        ServiceStatus status;
        address customer;
        uint256 claimTimestamp;
    }

    mapping (uint256 => CareObject) internal careObjects;

    Service[] internal services;

    address public tokenCareFund;
    address public tombTrackInventory;
    address public tombCareTeam;

    // Think about getters and mappings for additional accessibility, if needed
    // user to careObject/service 
}
