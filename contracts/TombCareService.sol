pragma solidity ^0.4.24;
import "./TombCareBase.sol";
import "./TestToken.sol";

contract TombCareService is TombCareBase {

    event ServiceCreated(uint256 _id,address _providerId,address _customerId);
    event ServiceJobDone();
    event ServiceCancelled();
    event ServiceClosed();

    TestToken public token;

    function createCareObject(
        uint256 _id,
        address _minerId,
        uint16 _typeObj,
        uint16 _status) public /*onlyCTO*/ whenNotPaused
    {
        CareObject memory _careObject = CareObject({
            id : _id,
            minerId : _minerId,
            typeObj : _typeObj,
            status : _status
        });

        careObjects[_id] = _careObject;

        // Just to make sure
        require(_id <= 4294967295);
    }

    // Just in case, need to think about deleting careObject and service

    function createService(
        uint256 _id,
        uint16 _serviceTypeId,
        address _providerId,
        uint256 _priceUsd,
        address _customerId) public whenNotPaused
    {
        Service memory _service = Service({
            id : _id,
            serviceTypeId : _serviceTypeId,
            providerId : _providerId,
            priceUsd : _priceUsd,
            status : ServiceStatus.NewOrder,
            customerId : _customerId,
            claimTimestamp : 0
        });

        uint256 _serviceId = services.length;
        services.push(_service); 

        // Just to make sure
        require(_serviceId <= 4294967295);

        emit ServiceCreated(_id,_providerId,_customerId);
    }

    function acceptService(uint256 _serviceId) public whenNotPaused {
        Service memory _service = services[_serviceId];
        
        require(_service.providerId == msg.sender);
        require(_service.status == ServiceStatus.NewOrder);

        _service.status = ServiceStatus.AssignProvider;

        // Transfer customer's tokens to us for safekeeping
    }

    // These two are weird, they don't do a lot
    function reportDoneJob(uint256 _serviceId) public {
        Service memory _service = services[_serviceId];

        require(_service.status == ServiceStatus.AssignProvider);
        _service.status = ServiceStatus.CompleteJob;
    }

    function startClaimResolution(uint256 _serviceId) public /*???*/{
        Service memory _service = services[_serviceId];

        require(_service.status == ServiceStatus.CompleteJob);
        _service.status = ServiceStatus.ClaimResolution;
    }
    ///

    function executeService(uint256 _serviceId) public /*onlyCTO*/ whenNotPaused {
        Service memory _service = services[_serviceId];

        require(_service.status == ServiceStatus.ClaimResolution);
        _service.status = ServiceStatus.ExecuteTransaction;
        _service.claimTimestamp = now;

        // Transfer holded user tokens to executor
    }



    function removeService() public whenNotPaused {
        // Is it much of a difference from refundService?
    }

    function getCareObject(uint256 _careObjectId) public view returns(address,uint16,uint16) {
        CareObject storage _careObject = careObjects[_careObjectId];

        return (
            _careObject.minerId,
            _careObject.typeObj,
            _careObject.status
        );
    }

    function getService(uint256 _serviceId) public view 
        returns (
            uint16 serviceTypeId,
            address providerId,
            uint256 priceUsd,
            ServiceStatus status,
            address customerId,
            uint256 claimTimestamp) 
    {
        Service storage _service = services[_serviceId];

        serviceTypeId = _service.serviceTypeId;
        providerId = _service.providerId;
        priceUsd = _service.priceUsd;
        status = _service.status;
        customerId = _service.customerId;
        claimTimestamp = _service.claimTimestamp;
    }
}
