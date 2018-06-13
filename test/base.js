contract('Base', function(accounts) {

  beforeEach(async () => {

    accounts = await web3.eth.getAccounts();
  
    manager = accounts[0];
  
    auction = await new web3.eth.Contract(interface)
  
        .deploy({ data: bytecode })
  
        .send({ from: manager, gas: '1000000' });
  
  });



  it("should assert true", function(done) {
    var base = Base.deployed();
    assert.isTrue(true);
    done();
  });
});
