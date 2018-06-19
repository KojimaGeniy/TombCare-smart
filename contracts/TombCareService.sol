pragma solidity ^0.4.24;
import "./TombCareBase.sol";
import "./TestToken.sol";

contract TombCareService is TombCareBase {

    event ServiceCreated(uint256 _id,address _provider,address _customer);
    event ServiceJobDone(uint256 _id,address _provider,address _customer);
    event ServiceCancelled(uint256 _id,address _provider,address _customer);
    event ServiceClosed(uint256 _id,address _provider,address _customer);

    TestToken public token;

    function createCareObject(
        uint256 _id,
        address _miner,
        uint16 _typeObj,
        uint16 _status) public /*onlyCTO*/ whenNotPaused
    {
        CareObject memory _careObject = CareObject({
            id : _id,
            miner : _miner,
            typeObj : _typeObj,
            status : _status
        });

        careObjects[_id] = _careObject;

        // Just to make sure
        require(_id <= 4294967295);
    }

    // Just in case, need to think about deleting careObject and service

    function createService(
        uint256 _careObjectId,
        uint16 _serviceTypeId,
        address _provider,
        uint256 _priceUsd,
        address _customer) public whenNotPaused
    {
        Service memory _service = Service({
            careObjectId : _careObjectId,
            serviceTypeId : _serviceTypeId,
            provider : _provider,
            priceUsd : _priceUsd,
            status : ServiceStatus.NewOrder,
            customer : _customer,
            claimTimestamp : 0
        });

        uint256 _serviceId = services.length;
        services.push(_service); 

        uint256 rate = token.rate();
        // First should be called approve for our contract from user
        token.transferFrom(msg.sender,this,_priceUsd/rate);

        // Just to make sure
        require(_serviceId <= 4294967295);

        emit ServiceCreated(_careObjectId,_provider,_customer);
    }

    function acceptService(uint256 _serviceId) public whenNotPaused {
        Service memory _service = services[_serviceId];
        
        require(_service.provider == msg.sender);
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
        // First should be called approve for our contract from user
        uint256 rate = token.rate();
        // WRONG Because we need to transfer the exact same amount of tokens
        // not affected by rate
        token.transferFrom(this,_service.provider,_service.priceUsd/rate);

        emit ServiceClosed(_service.careObjectId,_service.provider,_service.customer);
    }



    function removeService() public whenNotPaused {
        // Is it much of a difference from refundService?
    }

    function getCareObject(uint256 _careObjectId) public view returns(address,uint16,uint16) {
        CareObject storage _careObject = careObjects[_careObjectId];

        return (
            _careObject.miner,
            _careObject.typeObj,
            _careObject.status
        );
    }

    function getService(uint256 _serviceId) public view 
        returns (
            uint256 careObjectId,
            uint16 serviceTypeId,
            address provider,
            uint256 priceUsd,
            ServiceStatus status,
            address customer,
            uint256 claimTimestamp) 
    {
        Service storage _service = services[_serviceId];

        careObjectId = _service.careObjectId;
        serviceTypeId = _service.serviceTypeId;
        provider = _service.provider;
        priceUsd = _service.priceUsd;
        status = _service.status;
        customer = _service.customer;
        claimTimestamp = _service.claimTimestamp;
    }
}
