pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/* 
COPYRIGHT FRAN CASINO. 2019.
REQUIRE CLAUSES DEACTIVATED, TO BE DEFINED ACCORDING TO EACH SITUATION
SC FOR FINANCIAL FORENSIC COC
*/

contract Financial_forensics{

    
    struct Case {
        uint id;
        string name;
        string description;  // for QOs or conditions, location, description
        string entity_responsible;
        uint numberofevents;
        uint [] events_case; // the ID of the events of the investigation
        uint numberofinvestigators;
        address [] investigators; // investigators enrolled to the case
        address maker; // who  created
        string globalId; // global id in the case of external systems 
        bool status; // open case, closed case
        uint timestamp; // creation
        string hashIPFS; // refernce to manufacturing description, serial number, IMEI
    }
    // key is a uint, later corresponding to the product id
    // what we store (the value) is a Case
    // the information of this mapping is the set of cases.
    mapping(uint => Case) public cases; // public, so that w can access with a free function 

    struct Event {
        uint id;
        uint id_case;
        string type_event; // event category, eg. new evidence, new investigator added, new tool used, new report added.
        string description; // description
        string hashIPFS; // hash of event
        uint timestamp;
        address maker; // who  updates
    }

    mapping(uint => Event) public events; // public, so that w can access with a free function 
    // since mappings cant be looped and is difficult the have a count like array
    // we need a var to store the coutings  
    // useful also to iterate the mapping 

    uint public casesCount;
    uint public eventsCount;

    //PARTICIPANTS SHOULD BE FROM THE LIST OF STAKEHOLDERS IF ANY
    //address constant public stake5 = 0xE0F5206bbd039E7B0592D8918820024E2a743445;
    //address constant public stake4 = 0x50e00dE2c5cC4e456Cf234FCb1A0eFA367ED016E;
    //address constant public stake3 = 0x1533234Bd32f59909E1D471CF0C9BC80C92c97d2;
    address constant public investigator2 = 0x395BE1C1Eb316f82781462C4C028893e51d8b2a5;
    address constant public investigator = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // example of investigator
    address constant public adminaddr = 0xE0F5206bbd039e7b0592d8918820024E2A743222; // admin, current

    bool private  triggered;
    bool private  delivery;
    bool private  received;

    //Processes public p;
    //Stakeholders public s;

    // event, voted event. this will trigger when we want
    //  when a vote is cast for example, in the vote function. 
    event triggeredEvent (  // triggers new accepted order 
    );

    event updateEvent ( // triggers product status change
    );

    event reqEvent (
        uint indexed _caseId
    );


    constructor () public { // constructor, creates cases. we map starting from id=1,  hardcoded values of all
        addCase("Embezzlement Bank 1","Investigation for embezzlement in a Greek Bank","Hellenic Police","HP000001",1573564413,"QmY8xHZzhF1dGDJMa4f7siU3SPTW9pHFpxX8xxJzq6Y1W4");
        addCase("Money Laundering User A","Investigation for money laundering suspect A","Interpol","INTAAA2934",1573864513,"QmW5oPVT68rihULJ9y8szree9Jrrjqrhxtn5tjkeoQkuwF");
        addCase("Embezzlement Bank 2","Investigation for embezzlement in an European Bank","Europol","EUPfn398g",1574594486,"QmNbRXGouduUGV31mMYhpx3DqE4Ca48M5KmpgKxVD8V6oz");
        addEvent(1,"New Evidence", "Screenshot","QmbK6stJke3kQoH8t3di2qzzC1rRRvoXoRsnC2WGvZVVVP",1573564414); //
        addEvent(2,"New Evidence", "Document","QmbkbFcPpMLR5MTiKtsP8zpQYN9grWsaiTKGV2C9bAEiVE",1573564424); //
        addEvent(3,"New Report", "Report","QmbqGAjrJV9ybebK8TXq5MC2x4FWXaXq7sPp9jSCjcANbK",1573564435); //
        addInvestigatorCase(1, 0x395BE1C1Eb316f82781462C4C028893e51d8b2a5);
        //addComponent();
        triggered=false;
        delivery=false;
        received=false;
    }

    //CASE  OPERATIONS******************************************
    // enables CASE creation
    // get CASE
    // get total for externally looping the mapping
    // update others.

    // add CASE to mapping
    // our contract to be able to do that, from constructor
    // otherwise the conditions of the accepted contract could change
    function addCase (string memory _name, string memory _description, string memory _entity_responsible, string memory _globalID, uint _timestamp, string memory _hashIpfs) private {
        //require valid investigator.

        casesCount ++; // inc count at the begining. represents ID also. 
        cases[casesCount].id = casesCount; 
        cases[casesCount].name = _name;
        cases[casesCount].description = _description;
        cases[casesCount].entity_responsible = _entity_responsible;
        cases[casesCount].numberofinvestigators = 1;
        cases[casesCount].numberofevents = 0;                      
        cases[casesCount].maker = msg.sender;
        cases[casesCount].globalId = _globalID;
        cases[casesCount].status = true;
	    cases[casesCount].timestamp = _timestamp;
        cases[casesCount].hashIPFS = _hashIpfs;

    }

     // only specific stakeholders, can be changed
    function updateCaseDescription (uint _caseId, string memory _description) public { 
        require(_caseId > 0 && _caseId <= casesCount); 
        //require(_caseId.maker == msg.sender);

        cases[_caseId].description = _description;  // update conditions
        emit updateEvent(); // trigger event 
    }


     // only specific stakeholders, can be changed
    function testupdateEvent (uint _caseId) public { 
        require(_caseId > 0 && _caseId <= casesCount); 
        //require(_caseId.maker == msg.sender);

        cases[_caseId].numberofevents ++;  // update conditions
        emit updateEvent(); // trigger event 
    }

    function updateResponsible (uint _caseId, string memory _entity_responsible) public { 
		//require(_caseId.maker == msg.sender);        
		require(_caseId > 0 && _caseId <= casesCount); 

        cases[_caseId].entity_responsible = _entity_responsible;  // update conditions
        emit updateEvent(); // trigger event 
    }

    function addInvestigatorCase (uint _caseId, address _investigator) public { 
        require(_caseId > 0 && _caseId <= casesCount); 
        //require(_caseId.maker == msg.sender);

        cases[_caseId].numberofinvestigators ++;  // update conditions
        cases[_caseId].investigators.push(_investigator);
        emit updateEvent(); // trigger event 
    }
     
    // returns the number of products, needed to iterate the mapping and to know info about the order.
    function getNumberOfCases () public view returns (uint){
        return casesCount;
    }
    // function to check the contents of the contract, the customer will check it and later will trigger if correct
    // only customer can check it 
    // customer will loop outside for this, getting the number of products before with getNumberOfProducts
    function getCase (uint _caseId) public returns (Case memory) {
        require(_caseId > 0 && _caseId <= casesCount); 

        return cases[_caseId];
        emit reqEvent(_caseId); // trigger event 
    }

    function getCaseGlobalID (uint _caseId) public view returns (string memory) {
        require(_caseId > 0 && _caseId <= casesCount); 

        return cases[_caseId].globalId;
    }
 
    function getNumberofInvestigators (uint _caseId) public view returns (uint) {
       require(_caseId > 0 && _caseId <= casesCount); 

        return cases[_caseId].numberofinvestigators;
    }


    function getCaseHash (uint _caseId) public view returns (string memory) { // ipfs directory
        require(_caseId > 0 && _caseId <= casesCount);  

        return cases[_caseId].hashIPFS;
    }
    
    //EVENT OPERATIONS********************************************

    function addEvent (uint _caseId, string memory _type_event, string memory _description, string memory _hashIPFS, uint _timestamp) public {  // acts as update location
        require(_caseId > 0 && _caseId <= casesCount); 
        //require(valid investigator);


        eventsCount ++; // inc count at the begining. represents ID also. 
        events[eventsCount].id = eventsCount; 
        events[eventsCount].id_case = _caseId;
        events[eventsCount].type_event = _type_event;
        events[eventsCount].description = _description;
        events[eventsCount].hashIPFS = _hashIPFS;
        events[eventsCount].timestamp = _timestamp; 
        events[eventsCount].maker = msg.sender;   
        events[eventsCount] = Event(eventsCount,_caseId,_type_event,_description,_hashIPFS,_timestamp, msg.sender);
        cases[_caseId].events_case.push(eventsCount); // we store the trace reference in the corresponding event
        cases[_caseId].numberofevents++;
        //this will give us the set of ID traces about our caseid
        emit updateEvent();
    }

    // returns the number of  events for specific case
    function getNumberOfEventsCase (uint _caseId) public view returns (uint) {
        require(_caseId > 0 && _caseId <= casesCount); 
        
        return cases[_caseId].numberofevents;
    }

        // get the array of traces of a product, later we can loop them using getTrace to obtain the data
    function getEventsCase (uint _caseId) public view returns (uint [] memory)  {
        require(_caseId > 0 && _caseId <= casesCount); 

        return cases[_caseId].events_case;
    }

   
    //global events. useful for generic statistical purposes
    function getGlobalNumberOfEvents () public view returns (uint) {
        
        return eventsCount;
    }


    // get an specific event
    function getEvent (uint _eventId) public view returns (Event memory)  {
        require(_eventId > 0 && _eventId <= eventsCount); 

        return events[_eventId];
    }

    function getEventHash (uint _eventId) public view returns (string memory) { // ipfs directory
        require(_eventId > 0 && _eventId <= eventsCount);  

        return events[_eventId].hashIPFS;
    }


    //EVENT AND SC OPERATIONS********************************************************
    // computes hash of transaction
    // several event triggers

    function retrieveHashProduct (uint _caseId) public view returns (bytes32){ 
    	//require(_caseId > 0 && _caseId <= casesCount); 
        //computehash according to unique characteristics
        // hash has to identify a unique transaction so timestamp and locations and products should be used.
        // this example hashes a transaction as a whole. This hash is different from the IPFS hash and therefore can be used for other purposes
        return keccak256(abi.encodePacked(block.number,msg.data, cases[_caseId].id, cases[_caseId].name, cases[_caseId].description, cases[_caseId].numberofevents, cases[_caseId].maker));
    }

     //this function triggers the contract
    function triggerContract () public { 
        triggered=true;
        emit triggeredEvent(); // trigger event 

    }


}
