pragma solidity ^0.4.24;
import "./TombCareService.sol";


contract TombCareCore is TombCareService{
    constructor(address _tokenAddr) {
        token = TestToken(_tokenAddr);
    }

    function() external payable {
        
    }
}
