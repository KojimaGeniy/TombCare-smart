pragma solidity ^0.4.24;
import "./TombCareBase.sol";
import "./TokenI.sol";

contract TombCareService is TombCareBase {

    TokenI public token;

    /// @dev A mapping from service ID to amount of holded tokens
    mapping (uint256 => uint256) tokensHolded;

    event ServiceCreated(uint256 _id,address _provider,address _customer);
    event ServiceJobDone(uint256 _id,address _provider,address _customer);
    event ServiceCancelled(uint256 _id,address _provider,address _customer);
    event ServiceClosed(uint256 _id,address _provider,address _customer);

    /**
    * @dev Creates Care object (only by Regional Manager)
      @param _id ID of Care object.
      @param _miner Miner address who will get 5%.
      @param _typeObj Care object type.
      @param _status Care object status.
      @param _hash Data hash of Care object.
    */
    function createCareObject(
        uint256 _id,
        address _miner,
        uint16 _typeObj,
        uint16 _status,
        string _hash) public /*onlyManager*/ whenNotPaused
    {
        CareObject memory _careObject = CareObject({
            miner : _miner,
            typeObj : _typeObj,
            status : _status,
            dataHash : _hash
        });

        require(careObjects[_id].miner == address(0));
        careObjects[_id] = _careObject;

        // Just to make sure
        require(_id <= 4294967295);
    }

    /**
    * @dev Creates service request for Care object by user
      @param _careObjectId ID of Care object.
      @param _serviceTypeId Type of service.
      @param _provider Provider who will execute the job.
      @param _priceUsd Price in USD that will be paid for the job.
    */
    function createService(
        uint256 _careObjectId,
        uint16 _serviceTypeId,
        address _provider,
        uint256 _priceUsd) public whenNotPaused
    {
        require(careObjects[_careObjectId].miner != address(0));
        Service memory _service = Service({
            careObjectId : _careObjectId,
            serviceTypeId : _serviceTypeId,
            provider : _provider,
            priceUsd : _priceUsd,
            status : ServiceStatus.NewOrder,
            customer : msg.sender,
            claimTimestamp : 0
        });

        uint256 _serviceId = services.length;
        services.push(_service); 

        uint256 rate = token.rate();
        // First should be called approve for our contract from user
        token.transferFrom(msg.sender,this,_priceUsd/rate);
        tokensHolded[_serviceId] = _priceUsd/rate;

        // Just to make sure
        require(_serviceId <= 4294967295);

        emit ServiceCreated(_careObjectId,_provider,msg.sender);
    }


    function acceptService(uint256 _serviceId) public whenNotPaused {
        Service storage _service = services[_serviceId];
        
        require(_service.provider == msg.sender);
        require(_service.status == ServiceStatus.NewOrder);

        _service.status = ServiceStatus.AssignProvider;
    }


    function reportDoneJob(uint256 _serviceId) public {
        Service storage _service = services[_serviceId];

        require(_service.provider == msg.sender);
        require(_service.status == ServiceStatus.AssignProvider);

        _service.status = ServiceStatus.CompleteJob;
    }

    function startClaimResolution(uint256 _serviceId) public /*onlyManagers */{
        Service storage _service = services[_serviceId];

        require(_service.status == ServiceStatus.CompleteJob);
        _service.status = ServiceStatus.ClaimResolution;
    }

    function executeService(uint256 _serviceId) public /*onlyManagers*/ whenNotPaused {
        Service storage _service = services[_serviceId];

        require(_service.status == ServiceStatus.ClaimResolution);
        _service.status = ServiceStatus.TransactionExecuted;
        _service.claimTimestamp = now;

        CareObject memory _careObject = careObjects[_service.careObjectId];

        // Transfer holded user tokens to executor
        uint256 tokens = tokensHolded[_serviceId];
        // Create getter for this shit if it isn't working wtf

        // 5% goes to TokenCare Fund
        token.transfer(tokenCareFund,(tokens.mul(5))/100);
        // 5% goes to Miner
        token.transfer(_careObject.miner,(tokens.mul(5))/100);
        // 5% goes to TombTrack inventory        
        token.transfer(tombTrackInventory,(tokens.mul(5))/100);
        // 5% goes to TombCare team   
        token.transfer(tombCareTeam,(tokens.mul(5))/100);        
        // 80% goes to Executor        
        token.transfer(_service.provider,(tokens.mul(80))/100);

        emit ServiceClosed(_service.careObjectId,_service.provider,_service.customer);
    }


    function refundService(uint256 _serviceId) public /*onlyManagers*/ whenNotPaused {
        Service memory _service = services[_serviceId];        
        
        require(_service.status == ServiceStatus.ClaimResolution);

        removeService(_serviceId);        
    }

    /// @dev Cancel placed service, requires msg.sender == customer
    /// only on new placed services
    function cancelService(uint256 _serviceId) public whenNotPaused {
        Service memory _service = services[_serviceId];        
        
        require(msg.sender == _service.customer && _service.status == ServiceStatus.NewOrder);

        removeService(_serviceId);
    }


    /// @dev Remove service from requested services
    function removeService(uint256 _serviceId) internal {
        Service memory _service = services[_serviceId];

        uint256 tokens = tokensHolded[_serviceId];
        token.transfer(_service.customer,tokens);
        tokensHolded[_serviceId] = 0;

        delete services[_serviceId];
    }


    function getCareObject(uint256 _careObjectId) public view returns(address,uint16,uint16,string) {
        CareObject storage _careObject = careObjects[_careObjectId];

        return (
            _careObject.miner,
            _careObject.typeObj,
            _careObject.status,
            _careObject.dataHash
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
        Service memory _service = services[_serviceId];

        careObjectId = _service.careObjectId;
        serviceTypeId = _service.serviceTypeId;
        provider = _service.provider;
        priceUsd = _service.priceUsd;
        status = _service.status;
        customer = _service.customer;
        claimTimestamp = _service.claimTimestamp;
    }
}
