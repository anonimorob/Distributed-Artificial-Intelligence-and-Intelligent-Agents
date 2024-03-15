/**
* Name: Homework1
* Guest Party
* Author: Adele and Kat
*/

model FestivalProject

global {
	int numberOfPeople <- 10;
	int numberOfStores <- 6;
	int numberOfInfo <- 3;         
	int distanceThreshold <- 2;
	list<point> infoCenterPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];  //works for 3 infopoints
	
	
	/* Project2: Auction configs*/
	int numberOfAuction <- 1;
	
	// Time when auctioneers are created
	int auctionCreationMin <- 0;
	int auctionCreationMax <- 50;
	
	// Guest accepted price range min and max
	int guestAcceptedPriceMin <- 100;
	int guestAcceptedPriceMax <- 1500;
	        
    // Dutch auction configs
	int dutchAuctionMin <- 5;// bid decrease min
	int dutchAuctionMax <- 15;// bid decrease max 
	// The initial price of the item to sell, set above the max price so that no guest immediately wins
	int dutchPriceMin <- 1504;
	int dutchPriceMax <-1600;
	// Minimum price of the item, if the bids go below this the auction fails
	int auctionerMinimumValue <- 100;


	// initializing agents
	init {
		create Person number:numberOfPeople;
		create Store number:numberOfStores;
		create InfoCenter number:numberOfInfo;
		
		loop counter from: 1 to: numberOfPeople {
        	Person my_agent <- Person[counter - 1]; 
        	my_agent <- my_agent.setName(counter);	    	
        }
		
		loop counter from: 1 to: numberOfStores {
        	Store my_agent <- Store[counter - 1];
        	my_agent <- my_agent.setName(counter);
        }
        
        loop counter from: 1 to: numberOfInfo {
        	InfoCenter my_agent <- InfoCenter[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	infoCenterPoints[counter - 1] <- InfoCenter[counter - 1].location;
        	write "INFOCENTER LOCATION IS " + InfoCenter[counter - 1].location +"!!!";
        }
        
        /*Project2 */
        create Auctioneer number: 1; 
        loop counter from: 1 to: numberOfAuction{
        	Auctioneer my_agent <-Auctioneer[counter -1];
        	my_agent<- my_agent.setName(counter);
        }
        
        
	}
}

// defining skills  and aspect of species Person
species Person skills: [moving, fipa] {
	bool isHungry <- false ;//update: flip(0.02);
	bool isThirsty <- false;// update: flip(0.02);
	float prob_ht <- 0.005;
	string personName <- "Undefined";
	point targetPoint <- nil; 
	bool goingInfo <- false;
	bool goingStore <- false;
	
	//project2
	bool isAuctionParticipant <- false;
	bool goingAuction <- false;
	Auctioneer targetAuction;
	int guestMaxAcceptedPrice <- rnd(guestAcceptedPriceMin,guestAcceptedPriceMax);
	
	action setName(int num) {
		personName <- "Person " + num;
	}
	
	aspect base {	
		rgb agentColor <- rgb("green"); //0
		if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("purple");
		}
		
		draw circle(1) color: agentColor;
	}
	
// defining state of the Person hungry/thirsty 
	reflex stateUpdate
	{
		if(!isHungry){
			if(flip(prob_ht))
			 {
			 	isHungry <- true;
			 }
		}
		if(!isThirsty){
			if(flip(prob_ht))
			 {
			 	isThirsty <- true;
			 }
		}
	}

// enjoy the party until hungry or thirsty or wants to auction
	reflex beIdle when:targetPoint = nil
	{
		if (isHungry or isThirsty or isAuctionParticipant){
			targetPoint <- infoCenterPoints closest_to self.location;
			goingInfo <- true;
		}
		else{
		 	do wander;
		 	goingInfo <- false;
		}
	}
// Move to target (info or store) when thirsty/hungry
	reflex moveToTarget when: targetPoint != nil
	{	
		if !(isHungry or isThirsty or isAuctionParticipant){
			do wander;
			targetPoint <- nil;
			goingInfo <- false;
		}
		else{
			do goto target: targetPoint;
			//write personName + " Going to Target! " ;
		}
	}
	
	
	reflex enterInfo when: targetPoint != nil and goingInfo = true and location distance_to(targetPoint) < distanceThreshold
	{	
		ask InfoCenter at_distance distanceThreshold{
					//write myself.personName + ": Can you suggest me where to eat / drink " + self.infoName;
        			myself.targetPoint <- point(self.checkStore(myself.isHungry,myself.isThirsty,myself.isAuctionParticipant,myself.personName));
        			//swrite " targetPoint is :" + myself.targetPoint;
        }
        
		goingInfo <- false;
		if(isAuctionParticipant){
			goingAuction <- true;
		}else{
			goingStore <- true; 
		}
			
	}
	
	reflex enterStore when: targetPoint != nil and goingStore = true and location distance_to(targetPoint) < distanceThreshold
	{
		if (isThirsty) {
			ask Store {
				if self.hasDrink =true{
					//write myself.personName + " drank at store "+ self.storeName;
					myself.isThirsty <- false;
					}	
				}
			} 
		if (isHungry) {
			ask Store  {
				if self.hasFood =true{
					//write myself.personName + " ate at store "+ self.storeName;
					myself.isHungry <- false;
					}	
				}
			}
		goingStore <- false;
		targetPoint <- nil; 
	}
	
	reflex listen_messages when: (!empty(cfps))
	{
		message requestFromInitiator <- (cfps at 0);
		// the request's format is as follows: [String]
		if(requestFromInitiator.contents[0] = 'Start')
		{
			// If the guest receives a message from an auction selling its preferredItem,
			// the guest participates in that auction
			if(!isAuctionParticipant){
				if(flip(prob_ht)){
					// Send a message to the auctioner telling them the guest will participate
					write name + " joins " + requestFromInitiator.sender + "'s auction ";
					isAuctionParticipant <- true;
					targetAuction <- requestFromInitiator.sender;
					targetAuction.participants <+ self;
					targetPoint <- targetAuction.location; //todo: remove finding auction location from infocenter
				}		
			}
		}
		else if(requestFromInitiator.contents[0] = 'Stop')
		{ //End of auction
			write name + ' knows the auction is over.';
			isAuctionParticipant <- false;
			targetPoint <- nil;
			targetAuction <- nil;
		}
		else if(requestFromInitiator.contents[0] = 'Winner')
		{
			write name + ' won the auction ';
			isAuctionParticipant <- false;
			targetPoint <- nil;
			targetAuction <- nil;			
		}
	}
	
	reflex reply_messages when: (!empty(proposes))
	{
		message requestFromInitiator <- (proposes at 0);
		int offer <- int(requestFromInitiator.contents[1]);
		if (guestMaxAcceptedPrice >= offer) {
			do accept_proposal with: (message: requestFromInitiator, contents:[name + ", accept your offer "]);
		}
		else
		{
			do reject_proposal (message: requestFromInitiator, contents:[ name + ", accept your offer "]);
			targetPoint <- nil;
		}		
	} 
}

species Store {
	bool hasFood <- flip(0.5);
	bool hasDrink <- false;	
	string storeName <- "Undefined";
			
	action setName(int num) {
		if (hasFood) {
		storeName <- "Food Store " + num;
		} else {
		storeName <- "Drink Store " + num;
		}
	}
    
	
	aspect base {
		rgb storeColor <- rgb("lightgray"); //0
		
		if (hasFood) {
			hasDrink <-false;
			storeColor <- rgb("purple"); //2
		} else {
			hasDrink <- true;
			storeColor <- rgb("darkorange") ; //1
		}
		
		draw square(5) color: storeColor;
	}
}

species InfoCenter {
	string infoName <- "Undefined";
	
	action checkStore(bool hungry, bool thirsty, bool isAuctionParticipant, string personName) {
			bool found <-false;
			list<point> storesTarget;
			point auctionTarget;
					
			
			loop counter from: 1 to: numberOfStores {
				Store my_agent <- Store[counter - 1];
				ask Store{
						if(hungry){
							if  (self.hasFood=true){
								//write personName +" can eat at store " + point(self.location) ;
								storesTarget <+ self.location ;								
								}
							}
						else if(thirsty){
							if  (self.hasDrink=true){
								//write personName +" can drink at store " + point(self.location) ;
								storesTarget <+ self.location ;	
								}
							}	
	        	}
        	}
        	
        	loop counter from: 1 to: numberOfAuction {
        		Auctioneer my_agent <- Auctioneer[counter - 1];
				ask Auctioneer{
					if(isAuctionParticipant and self.auctionInProgress=true){
						write personName +" can participate " + point(self.location) ;
						auctionTarget <- self.location;						
					}	
	        	}
        	}
        	
        	if !(empty(storesTarget))
	        {	
	        	return storesTarget closest_to self.location;
	        }  
	        
        	if( !(empty(auctionTarget))){
        		if(isAuctionParticipant){
	        		return auctionTarget ;
	        	}
        	} 	
        	
        	 		
	}


	action setName(int num) {
		infoName <- "Info " + num;
	}
	
	aspect base {
		rgb agentColor <- rgb("lightgreen");
		
		draw triangle(5) color: agentColor;
	}
	
}

// Define the Auctioneer species
species Auctioneer skills:[fipa, moving] {
    float dutchPrice <- 100.0; // Starting price for the Dutch auction
    float minimumPrice <- 50.0; // Minimum price threshold for the auction
    list<Person> participants; // List of potential buyers in the auction
    bool auctionInProgress <- false; // Flag to track if the auction is currently in progress

    // Reflex to inform all Persons that the auction is starting with a Call For Proposal (CFP)
    //todo: add interested Person to participants list
    reflex informAgents when: cycle mod 10 = 0 {
    	write name + " starting Dutch Auction soon" ;
    	// Start a conversation with all possible buyers
        do start_conversation (to: list(Person), protocol: 'fipa-propose', performative: 'cfp', contents: ['Start']);
    }
    
    /*
	 * sets auctionStarted to true when interestedGuests are within a distance of 13 to the auctioner.
	 */
	reflex startAuction when: !auctionInProgress and !empty(participants) and (participants max_of (location distance_to(each.location))) <= 13
	{
		write name + " All the people Are Around: starting the auction";
		auctionInProgress <- true;
	}
	

    // Reflex to handle auction process
    reflex manageAuction when: auctionInProgress and !empty(participants){
        if (auctionInProgress) {//todo: replace this check with type of auction?
            if (dutchPrice > minimumPrice) {
            	write name + ' receives reject messages from participants';
                // Decrease price over time to simulate Dutch auction
                dutchPrice <- dutchPrice - 1.0;
                do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'propose', contents: ['Buy my merch at ', dutchPrice]);
            } else {
                // Auction ends if price goes below minimum value
                auctionInProgress <- false;
                write name + ' Auction ended without sale';
                do start_conversation (to: list(Person), protocol: 'fipa-propose', performative: 'inform', contents: ['Stop']);
            	participants <- []; //todo: send only to participants?
            }
        }
    }
    
    
    /*
	 * Dutch auction: auctioner sends a propose message and guests can reply with accept or reject messages. The auction ends with the first accept.
	 */
	reflex readAcceptMessages when: auctionInProgress and !empty(accept_proposals)
	{
			write name + ' receives accept messages';
			
			loop a over: accept_proposals {
				write name + ' got accepted by ' + a.sender + ': ' + a.contents;
				do start_conversation (to: a.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Winner']);
			}
			auctionInProgress <- false;
			//end of auction
			write name + ' Auction ended with sale';
            do start_conversation (to: list(Person), protocol: 'fipa-propose', performative: 'inform', contents: ['Stop']);
	}
	
	string name <- "NoNameAuctioner";
	action setName(int num) {
		name <- "Auctioneer " + num;
	}

    // Aspect to represent the Auctioneer visually
    aspect base {
        draw square(5) color: #gray;
    }
   
}


/*
species Initiator skills: [fipa]{
	reflex send_request when: (time=1){
		Participant p <- Participant at 0;
		write 'send message';
		do start_conversation (to:: [p], protocol::'fipa-request', performative::'request', contents::['go sleeping']);
	}
	reflex read_agree_message when: !(empty(agrees)){
		loop a over: agrees{
			write 'agree message with content: '+ string(a.contents);
		}
	}
	reflex read_failure_message when: !(empty(failures)){
		loop f over: failures{
			write 'failure message with content: ' + string(f.contents);
		}
	}
}

species Participant skills: [fipa]{
	reflex reply_messages when: !(empty(requests)){
		message requestFromInitiator <- (requests at 0);
		
		do agree with: (message: requestFromInitiator, contents: ['I will']);
			
		write "inform the initiator of the failure";
		do failure (message: requestFromInitiator, contents: ['The bed is broken']);
	}
}
 */
 
experiment myExperiment type:gui {
	output {
		display myDisplay {
			species Person aspect:base;
			species Store aspect:base;
			species InfoCenter aspect:base;
			
			/* Project2 */
			species Auctioneer aspect:base;
		}
	}
}
