pragma solidity ^0.4.23;
import "./TombCareService.sol";


contract TombCareCore is TombCareService{
    constructor(address _tokenAddr) public {
        token = TokenI(_tokenAddr);

        tokenCareFund = 0x9de88e0a9Fa6d30dF271eec31C55eE0358E8f7f9;
        tombTrackInventory = 0x9de88e0a9Fa6d30dF271eec31C55eE0358E8f7f9;
        tombCareTeam = 0x9de88e0a9Fa6d30dF271eec31C55eE0358E8f7f9;
    }

    function() external payable {
        
    }
}
