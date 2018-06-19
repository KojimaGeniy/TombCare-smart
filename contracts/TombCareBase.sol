pragma solidity ^0.4.24;
import "./TombCareAccessControl.sol";
import "./TestToken.sol";
//import "./utils/SafeMath.sol";

contract TombCareBase is TombCareAccessControl{
    using SafeMath for uint256;


    //--STORAGE--//
    enum ServiceStatus { 
        NewOrder, 
        AssignProvider, //it's about accepting job
        CompleteJob, 
        ClaimResolution, 
        ExecuteTransaction 
    }

    // Keeping in mind storing photo + data hash
    struct CareObject {
        uint256 id;
        address miner;
        uint16 typeObj;
        uint16 status;
        //hash here
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

    CareObject[] internal careObjects;

    Service[] internal services;

    address public tokenCareFund;
    address public tombTrackInventory;
    address public tombCareTeam;

    // Array of managers, it's okay if they are up to 200

    // Prices going from elsewhere

    // Something with users (holders)
    // we also have miners  

    //Something with service providers (workers)

}
  