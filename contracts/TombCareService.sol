pragma solidity ^0.4.24;
import "./TombCareBase.sol";

contract TombCareService is TombCareBase {

    event CareObjectCreated();
    event ServiceCreated();
    event ServiceJobDone();
    event ServiceCancelled();
    event ServiceClosed();

    function createCareObject(
        uint256 _id,
        address _minerID,
        uint16 _typeObj,
        uint16 _status) public /*onlyCTO*/ whenNotPaused
    {
        CareObject memory _careObject = CareObject({
            id : _id,
            minerID : _minerID,
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
        uint256 _priceUsd,
        address _customerId) public whenNotPaused
    {
        Service memory _service = Service({
            id : _id,
            serviceTypeId : _serviceTypeId,
            providerId : address(0),
            priceUsd : _priceUsd,
            status : ServiceStatus.NewOrder,
            customerId : _customerId,
            claimTimestamp : 0
        });

        uint256 _serviceId = services.length;
        services.push(_service); 

        // Just to make sure
        require(_serviceId <= 4294967295);
    }

    function acceptService(uint256 _serviceID) public /*onlyProvider?*/ whenNotPaused {
        Service memory _service = services[_serviceID];

        _service.status = ServiceStatus.AssignProvider;
        _service.providerId = 
    }

    function reportDoneJob() public {

    }

    function startClaimAndResolution() public /*???*/{

    }

    function executeService(uint256 _serviceID) public /*onlyCTO*/ whenNotPaused {
        Service memory _service = services[_serviceID];

        _service.status = ServiceStatus.ExecuteTransaction;
        _service.claimTimestamp = now;
    }

    function removeService() public whenNotPaused {

    }

    function getCareObject(uint256 _careObjectID) public view returns(address,uint16,uint16) {
        CareObject storage _careObject = careObjects[_careObjectID];

        return (
            _careObject.minerID,
            _careObject.typeObj,
            _careObject.status
        );
    }

    function getService(uint256 _serviceID) public view 
        returns (
            uint16 serviceTypeId,
            address providerId,
            uint256 priceUsd,
            ServiceStatus status,
            address customerId,
            uint256 claimTimestamp) {
        Service storage _service = services[_serviceID];

        serviceTypeId = _service.serviceTypeId;
        providerId = _service.providerId;
        priceUsd = _service.priceUsd;
        status = _service.status;
        customerId = _service.customerId;
        claimTimestamp = _service.claimTimestamp;
    }
}
