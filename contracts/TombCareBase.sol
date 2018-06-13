pragma solidity ^0.4.24;
import "./TombCareAccessControl.sol";

contract TombCareBase is TombCareAccessControl{


    //--STORAGE--//
    enum ServiceStatus { 
        NewOrder, 
        AssignProvider, //it's about accepting job
        CompleteJob, 
        ClaimResolution, 
        ExecuteTransaction 
    }

    // MinerID for now address
    // Keeping in mind storing photo + data hash
    struct CareObject {
        uint256 id;
        address minerId;
        uint16 typeObj;
        uint16 status;
        //hash here
    }

    // ProviderID and customerId for now addresses
    // Price in usd oh fu
    // No need to store ID
    struct Service {
        uint256 id;
        uint16 serviceTypeId;
        address providerId;
        uint256 priceUsd;
        ServiceStatus status;
        address customerId;
        uint256 claimTimestamp;
    }

    CareObject[] internal careObjects;

    Service[] internal services;

    address public tokenCareFund;
    address public tombTrackInventory;
    address public tombCareTeam;

    // Array of managers, it's okay if they are up to 200

    // Prices going from elsewhere
    // how do they link up  prices, services, and providers??? Mystery 


    // Something with users (holders)
    // we also have miners  

    //Something with service providers (workers)

}
  