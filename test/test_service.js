const { assert } = require('chai');  
const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider);

const TombCareCore = artifacts.require("./TombCareCore")
const TestToken = artifacts.require("./TestToken");
const FINNEY = 10**15;

contract('TombCareService', function(accounts) {
  const [firstAccount, secondAccount,thirdAccount] = accounts;
  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  before(async () => {
    TokenInstance = await TestToken.new();
    CoreInstance = await TombCareCore.new(TokenInstance.address);
  });

  it("Creates care object", async () => {
    await CoreInstance.createCareObject(1,secondAccount,1,1,"0xd89a3fa2ddbed0a17fa2954b1060f41591c216155b688a7b5af5a2d7c003bb11");
    assert.notEqual((await CoreInstance.getCareObject.call(1))[0],0);
  });

  it("Creates service", async () => {
    await TokenInstance.mint(firstAccount,5);
    await TokenInstance.approve(CoreInstance.address,5);
    await CoreInstance.createService(1,1,thirdAccount,5);
    assert.notEqual((await CoreInstance.getService(0))[2],0)
  })

  it("Fails to create service because of not approved", async () => {
    await TokenInstance.mint(firstAccount,10);
    await TokenInstance.approve(CoreInstance.address,3);
    try {
      await CoreInstance.createService(1,1,thirdAccount,5);
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }
  });

  it("Accepts service by provider", async () => {
    await CoreInstance.acceptService(0,{from: thirdAccount});
    assert.equal((await CoreInstance.getService(0))[4],1);
  })
  it("Reports job done by provider", async () => {
    await CoreInstance.reportDoneJob(0,{from: thirdAccount});
    assert.equal((await CoreInstance.getService(0))[4],2);
  })
  it("Starts claim resolution by regional manager (FIX THAT)", async () => {
    await CoreInstance.startClaimResolution(0,{from: firstAccount});
    assert.equal((await CoreInstance.getService(0))[4],3);
  })
  it("Executes service by regional manager", async () => {
    console.log("Core",await TokenInstance.balanceOf(CoreInstance.address))
    console.log("User",await TokenInstance.balanceOf(firstAccount))
    // await TokenInstance.approve(CoreInstance.address,3);
    
    await CoreInstance.executeService(0,{from: firstAccount});
    console.log("Core",(await TokenInstance.balanceOf(CoreInstance.address)).toNumber())
    console.log("User",(await TokenInstance.balanceOf(firstAccount)).toNumber())
    console.log("Fund",(await TokenInstance.balanceOf('0x9de88e0a9Fa6d30dF271eec31C55eE0358E8f7f9')).toNumber())
    console.log("Provider",(await TokenInstance.balanceOf(thirdAccount)).toNumber())
    
    assert.equal((await CoreInstance.getService(0))[4],4);
  })
  // and go with TDD style
});

// contract('MineorityMarket create invoice and pay for it', function(accounts) {
//   const [firstAccount, secondAccount] = accounts;
//   function sleep(ms) {
//     return new Promise(resolve => setTimeout(resolve, ms));
//   }
  
//   before(async () => {
//     MarketInstance = await MineorityMarket.new();
//   });

//   it("calls IPFS and creates invoice", async () => {
//     await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.utils.toWei('0.4','ether')});
//     await MarketInstance.queryIPFS("QmPtyfdTUx4BQRXGK7Twgor1n8GRMK6FhchUMyQX6ourff");
//     await sleep(16000);
//     assert.notEqual((await MarketInstance.getInvoice.call(firstAccount))[0].toNumber(),0);
//   });

//   it("pays the invoice and checks for tokens", async () => {
//     await MarketInstance.executeOrder(firstAccount,{ from:firstAccount, value: 570000000000000000 });
//     assert.equal((await MarketInstance.balanceOf.call(firstAccount)).toNumber(),2,"No tokens!");
//   });

// });
