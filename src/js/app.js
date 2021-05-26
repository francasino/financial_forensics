App = {
  web3Provider: null,
  contracts: {},
  //account: '0x0',
  account: '0xe4acee4e6656f721bb06d1dc72149274558ceab0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Financial_forensics.json", function(Financial_forensics) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Financial_forensics = TruffleContract(Financial_forensics);
      // Connect provider to interact with contract
      App.contracts.Financial_forensics.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Financial_forensics.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.reqEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },

  render: function() {
    var electionInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    //  IF THIS FAILS YOU HAVE TO HARDCODE THE ACCOUNT USING THE FIRST ONE OF GANACHE CLI FOR EXAMPLE
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    var candidateId = $('#candidatesSelect').val();
    var caseevent = $('#Case').val(); 
    var typeevent = $('#Type').val(); 
    var descevent = $('#Description').val(); 
    var dateevent = $('#Date').val(); 
    var hashevent = $('#Hash').val();   
    var statusevent ="active"; 
    if (caseevent != null && typeevent != null && descevent != null && dateevent != null && hashevent != null){
         //testupdateEvent

          // App.contracts.Financial_forensics.deployed().then(function(instance) {
          // return instance.testupdateEvent(caseevent, { from: App.account });
          //   }).then(function(result) {
          //    // Wait for votes to update
          //     //$("#content").hide();
          //    // $("#loader").show();
          //   }).catch(function(err) {
          //     console.error(err);
          //   });
            App.contracts.Financial_forensics.deployed().then(function(instance) {
          return instance.addEvent(caseevent,typeevent,descevent,hashevent,statusevent,dateevent,{ from: App.account, gas:1000000 }); // you have to specify gas in case of call above 90k gas
            }).then(function(result) {
             // Wait for votes to update
              //$("#content").hide();
             // $("#loader").show();
            }).catch(function(err) {
              console.error(err);
            });      
      }     


    App.contracts.Financial_forensics.deployed().then(function(instance) {
      forensicsInstance = instance;
      return forensicsInstance.casesCount();
    }).then(function(casesCount) {
      var candidatesResults = $("#candidatesResults");
      candidatesResults.empty();

      //var candidatesSelect = $('#candidatesSelect');
      //candidatesSelect.empty();


       if (candidateId == "ALL"){

          for (var i = 1; i <= casesCount; i++) {
            forensicsInstance.cases(i).then(function(cases) {
              var id = cases[0];
              var name = cases[1];
              var description = cases[2];
              var responsible = cases[3];
              var events = cases[4];
              var investigators = cases[5];
              var date = cases[9];
              var status = cases[8];
              var globalid = cases[7];
              // var addr = cases[6];
              var hash = cases[10];
              var ipfslink = "https://ipfs.io/ipfs/"+hash;

              var ts = new Date(date*1000);
              //console.log(ts.toDateString());

              // Render candidate Result
              var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</th><td>" + description + "</th><td>" + responsible + "</th><td>" + investigators + "</td><td>" + events + "</td><td>" + ts.toDateString() + "</td><td>" + status + "</td><td>" + globalid + "</td><td> '<a href=" + ipfslink + ">"+hash+"</a>' </td></tr>"
              candidatesResults.append(candidateTemplate);

              // Render candidate ballot option
              //var candidateOption = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quantity + "</td><td>" + desc + "</td><td>" + globalid + "</td><td>" + addr + "</td><td>" + hash + "</td></tr>"
              //candidatesSelect.append(candidateOption);
            });
          }
      }else {
          forensicsInstance.cases(candidateId).then(function(cases) {
              var id = cases[0];
              var name = cases[1];
              var description = cases[2];
              var responsible = cases[3];
              var events = cases[4];
              var investigators = cases[5];
              var date = cases[9];
              var status = cases[8];
              var globalid = cases[7];
              // var addr = cases[6];
              var hash = cases[10];
              var ipfslink = "https://ipfs.io/ipfs/"+hash;
              var ts = new Date(date*1000);
              // Render  result if no error
              if (id == 0 || id == null){
                var candidateTemplate = "<tr><th>" + "ID does not exist" + "</tr>";
                candidatesResults.append(candidateTemplate);
              }else{
                var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</th><td>" + description + "</th><td>" + responsible + "</th><td>" + investigators + "</td><td>" + events + "</td><td>" + ts.toDateString() + "</td><td>" + status + "</td><td>" + globalid + "</td><td> '<a href=" + ipfslink + ">"+hash+"</a>' </td></tr>"
                candidatesResults.append(candidateTemplate);
              }  
            });

      }
      //return pagonisInstance.voters(App.account);
    }).then(function(show) {
      // show always checker
      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });

  },

  castVote: function() {
      // var case = document.forms["RegForm"]["Case"];     
      // var description = document.forms["RegForm"]["Description"];  
      // var type =  document.forms["RegForm"]["Type"];  
      // var date = document.forms["RegForm"]["Date"]; 
      // var hash = document.forms["RegForm"]["Hash"];
      // var address = document.forms["RegForm"]["Addr"]; 
      //var case = $('#Case').val();

        // forensicsInstance.cases(case).then(function(cases) {
        //       var id = cases[0];
 
        //       // Render  result if no error
        //       if (id == 0 || id == null){
        //         window.alert("Please enter your name."); 
        //         name.focus(); 
        //         return false;
        //       }else{

      // web3.eth.getCoinbase(function(err, account) {
      // if (err === null) {
      //   App.account = account;
      //   $("#accountAddress").html("Your Account: " + account);
      // }
      // });

      // var case = 1;    
      // var type = "test";
      // var description = "testd";
      // var date = 1573564435;
      // var hash = "QmdUvd3tb4TRM4pwMrLYEmgo7JDtwxnwXB1Wfa3gtgnwW1";



    //   App.contracts.Financial_forensics.deployed().then(function(instance) {
    //   forensicsInstance = instance;
    //   return forensicsInstance.casesCount();
    //    }).then(function(show) {
    //   // show always checker
    //   //loader.hide();
    //  // content.show();
    // }).catch(function(error) {
    //   console.warn(error);
    // });
      
              // App.contracts.Financial_forensics.deployed().then(function(instance) {
              //   return instance.addEvent(case,type,description,hash,date,{ from: App.account });
              //     }).then(function(result) {
                    // Wait for votes to update
                    //$("#content").hide();
                    //$("#loader").show();
                  // }).catch(function(err) {
                  //   console.error(err);
                  // });
          //}
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
