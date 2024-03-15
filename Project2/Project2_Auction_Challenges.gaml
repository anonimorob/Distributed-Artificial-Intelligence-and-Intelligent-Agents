/**
* Name: Homework2
* Author: Kat and Adele
* Tags: 
*/

model FestivalProject

global {
	int numberOfPeople <- 80;
	int numberOfStores <- 6;
	int numberOfInfo <- 3;         
	int distanceThreshold <- 2;
	list<point> infoCenterPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];  //works for 3 infopoints
	list<int> priceSoldDutch;
	list<int> priceSoldEng;
	list<int> priceSoldSeal;
		
	/* Project2: Auction configs*/
	int numberOfAuction <- 3;
	
	// Time when auctioneers are created
	int auctionCreationMin <- 0;
	int auctionCreationMax <- 50;
	
	// Guest accepted price range min and max
	int guestAcceptedPriceMin <- 100;
	int guestAcceptedPriceMax <- 1000;
	        
    // Dutch auction configs
	int dutchAuctionMin <- 5;// bid decrease min  
	int dutchAuctionMax <- 15;// bid decrease max 
	// The INITIAL price of the item to sell, set above the max price so that no guest immediately wins
	int dutchPriceMin <- 1300;
	int dutchPriceMax <-1500;
	// Minimum price of the item, if the bids go below this the auction fails
	int auctionerMinimumValue <- 100;

	
	list<string> itemsAvailable <- ["Technology","Home","Clothes","Vinted"];
	list<string> auctionTypes <- ["Dutch", "English","Sealed"];
	// English auction configs
	int engAuctionMinRaise <- 30;
	int engAuctionMaxRaise <- 60;
	
	// The initial price of the item to sell
	int engAuctionMinPrice <- 0;
	int engAuctionMaxPrice <-1500;
	
	// initializing agents
	init {
		create Person number:numberOfPeople
		{
			preferredItem <- itemsAvailable[rnd(length(itemsAvailable) - 1)];
		}
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
        create Auctioneer number: numberOfAuction
        {
        	 	itemType<-itemsAvailable[rnd(length(itemsAvailable) - 1)];
        	 	auctionType <-auctionTypes[rnd(length(auctionTypes)-1)];
        }
        loop counter from: 1 to: numberOfAuction{
        	Auctioneer my_agent <-Auctioneer[counter -1];
        	my_agent<- my_agent.setName(counter);
        	//my_agent<- my_agent.setItem(itemsAvailable[counter-1]);
        }
        
        
	}
}

// defining skills  and aspect of species Person
species Person skills: [moving, fipa] {
	bool isHungry <- false ;//update: flip(0.02);
	bool isThirsty <- false;// update: flip(0.02);
	float prob_ht <- 0.002;
	float prob_action <- 0.1;
	string personName <- "Undefined";
	point targetPoint <- nil; 
	bool goingInfo <- false;
	bool goingStore <- false;
	
	//project2
	bool isAuctionParticipant <- false;
	bool goingAuction <- false;
	Auctioneer targetAuction;
	int guestMaxAcceptedPrice <- rnd(guestAcceptedPriceMin,guestAcceptedPriceMax);
	
	string preferredItem;
	
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
		
		draw sphere(1.5) color: agentColor;
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
		if(requestFromInitiator.contents[0] = 'Winner')
		{
			write name + ' won the auction ' + preferredItem;
			isAuctionParticipant <- false;
			targetPoint <- nil;
			targetAuction <- nil;			
		}
		else if(requestFromInitiator.contents[0] = 'Start'and requestFromInitiator.contents[1] = preferredItem)
		{
			// If the guest receives a message from an auction selling its preferredItem,
			// the guest participates in that auction
			if(!isAuctionParticipant){
				if(flip(prob_action)){
					// Send a message to the auctioner telling them the guest will participate
					write name + " joins " + requestFromInitiator.sender + "'s auction of type "+requestFromInitiator.contents[2];
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
		//Time to send bid for sealed bidding
		else if(requestFromInitiator.contents[0] = 'Bid For Sealed')
		{
			do start_conversation (to: requestFromInitiator.sender, protocol: 'fipa-propose', performative: 'propose', contents: ['This is my offer', guestMaxAcceptedPrice]);
			write " Sending bid for sealed bidding " ;
			targetAuction <- nil;
			targetPoint <- nil;
		}
		//next round for english bidding
		else if(requestFromInitiator.contents[0] = 'Bid for English')
		{
			int currentBid <- int(requestFromInitiator.contents[1]);
			//can bid more
			if (guestMaxAcceptedPrice > currentBid) 
			{
				int newBid <- currentBid + rnd(engAuctionMinRaise, engAuctionMaxRaise);
				if(newBid > guestMaxAcceptedPrice)
				{
					newBid <- guestMaxAcceptedPrice;
				}
				//write name + ' sending propose ' + newBid;
				do start_conversation (to: requestFromInitiator.sender, protocol: 'fipa-propose', performative: 'propose', contents: ['This is my offer', newBid]);
			}
			//can't bid more
			else
			{
				write name + ": Price is too high I would like to withdraw ";
				do reject_proposal (message: requestFromInitiator, contents: [" Price is too high I would like to withdraw"]);
				targetAuction <- nil;
				targetPoint <- nil;
			}
		}
		
		}

	
	reflex reply_messages when: (!empty(proposes))
	{
		message requestFromInitiator <- (proposes at 0);
		int offer <- int(requestFromInitiator.contents[1]);
		if (guestMaxAcceptedPrice >= offer) {
			 priceSoldDutch<+guestMaxAcceptedPrice;
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
		
		draw cylinder(3,3) color: storeColor;
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
		
		draw pyramid(3) color: agentColor;
	}
	
}



// Define the Auctioneer species
species Auctioneer skills:[fipa, moving] {
	rgb myColor <- #blueviolet;
    float dutchPrice <- 100.0; // Starting price for the Dutch auction
    float minimumPrice <- 50.0; // Minimum price threshold for the auction
    list<Person> participants; // List of potential buyers in the auction
    bool auctionInProgress <- false; // Flag to track if the auction is currently in progress
	string itemType<- ""; //item type selled by this auctioneer
	string auctionType <-"";
	int currentBid <- 0;
	string currentWinner <- nil;
	message winner <- nil;
	
    // Reflex to inform all Persons that the auction is starting with a Call For Proposal (CFP)
    //todo: add interested Person to participants list
    reflex informAgents when: cycle mod 10 = 0 and  !auctionInProgress {
    	write name + " starting "+auctionType+ " auction soon of type " + itemType ;
    	// Start a conversation with all possible buyers
        do start_conversation (to: list(Person), protocol: 'fipa-propose', performative: 'cfp', contents: ['Start',itemType,auctionType]);
    }
    
    reflex sellHistory when: cycle mod 100 = 0{
    	if (!empty(priceSoldDutch))
    	{
    		write "DUTCH HISTORY";
    		loop counter from: 0 to: (length(priceSoldDutch)-1){
        		write priceSoldDutch[counter];
       	 }
    	}
    	 if (!empty(priceSoldSeal))
    	{
    		write "SEALED HISTORY";
    		loop counter from: 0 to: (length(priceSoldSeal)-1){
        		write priceSoldSeal[counter];
       	 }
    	}
    	if (!empty(priceSoldEng))
    	{
    		write "ENGLISH HISTORY";
    		loop counter from: 0 to: (length(priceSoldEng)-1){
        		write priceSoldEng[counter];
       	 }
    	}}
    
    /*
	 * sets auctionStarted to true when interestedGuests are within a distance of 13 to the auctioner.
	 */
	reflex startAuction when: !auctionInProgress and !empty(participants) and (participants max_of (location distance_to(each.location))) <= 20
	{
		write name + " All the people Are Around: starting the "+auctionType+" auction for " + itemType;
		auctionInProgress <- true;
	}
	

    // Reflex to handle auction process
    reflex manageAuction when: auctionInProgress and !empty(participants){
        if (auctionInProgress) {
          if(auctionType ="Dutch")
          {
	            if (dutchPrice > minimumPrice) {
	            	write name + ' receives reject messages from participants';
	                // Decrease price over time to simulate Dutch auction
	                dutchPrice <- dutchPrice - rnd(dutchAuctionMin,dutchAuctionMax);
	                do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'propose', contents: ['Buy my merch at ', dutchPrice]);
	                
	            } else {
	                // Auction ends if price goes below minimum value
	                auctionInProgress <- false;
	                write name + ' Auction ended without sale' + itemType;
	                do start_conversation (to: list(Person), protocol: 'fipa-propose', performative: 'inform', contents: ['Stop']);
	            	participants <- []; //todo: send only to participants?
	            }
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
				write name + ' got accepted by ' + a.sender + ': ' + a.contents + itemType;
				//priceSoldDutch<+ a.contents;
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
	action setItem(string type) {
		itemType <-  type;
	}
	
	
	reflex getProposes when: (!empty(proposes))
	{
		if(auctionType = "Sealed")
		{
			auctionInProgress <- false;

			loop p over: proposes {
				write name + ' got an offer from ' + p.sender + ' of ' + p.contents[1] + ' kronas.';
				if(currentBid < int(p.contents[1]))
				{
					currentBid <- int(p.contents[1]);
					currentWinner <- p.sender;
					winner <- p;
				}
			}
			if winner != nil{
				do start_conversation (to: winner.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Winner']);
				write name + ' bid ended. Sold to ' + currentWinner + ' for: ' + currentBid;
				priceSoldSeal<+currentBid;
			}
			if !empty(participants){
			do accept_proposal with: (message: winner, contents: ['Item is yours']);
			do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'cfp', contents: ["Stop"]);
			}
			currentBid <- 0;
			currentWinner <- nil;
			winner <- nil;
			participants <- [];
		}
		else if(auctionType = "English")
		{
			loop p over: proposes {
				write name + ' got an offer from ' + p.sender + ' of ' + p.contents[1] + ' kronas.';
				if(currentBid < int(p.contents[1]))
				{
					currentBid <- int(p.contents[1]);
					currentWinner <- p.sender;
					winner <- p;
				}
			}
			
		}
	}
		/*
	 * Reject messages are used in Dutch and English auctions.
	 * Dutch: Starting from high bid and goes on as long as everybody rejects the proposal. Here, we decrese the price of the item.
	 * If the price goes below the minimum expected price, the auction ends.
	 * English: Reject messages mean that participants don't wish to bid more and are out of the auction.
	 * If everyone is out or just one person left, the auction ends.
	 */
	reflex receiveRejectMessages when: auctionInProgress and !empty(reject_proposals)
	{
		 if(auctionType = "English")
		{	
			loop r over: reject_proposals 
			{
				participants >- r.sender;
			}
			if(length(participants) < 2)
			{
				auctionInProgress <- false;

				if(currentBid < auctionerMinimumValue)
				{
					write name + ' bid ended. No more auctions !';
				}
				else
				{
					write 'Bid ended. Winner is: ' + currentWinner + ' with a bid of ' + currentBid;	
					do start_conversation (to: winner.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Winner']);
					priceSoldEng<+currentBid;
					currentBid <- 0;
					currentWinner <- nil;
					winner <- nil;
				}
				if(!empty(participants))
				{
					do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'cfp', contents: ["Stop"]);
				}
				participants <- [];
			}
		}
	}
		/*
	 * Dutch: every iteration, it sends the decreased price of the item to the participants which they can accept of reject
	 * English: every iteration, tells guests about the current highest bid that they need to outbid
	 * Sealed: Start of the auction which is only one iteration
	 */
	reflex sendAuctionInfo when: auctionInProgress and time >= 50 and !empty(participants){
		if(auctionType = "Dutch")
		{
			write name + ' sends the offer of ' + dutchPrice +' kronas to participants';
			do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'propose', contents: ['Buy my merch', auctionType, dutchPrice]);
		}
		else if(auctionType = "English")
		{
			write 'Auctioner ' + name + ': current bid is: ' + currentBid + '. Offer more or miss your chance!';
			do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'cfp', contents: ["Bid for English", currentBid]);
		}
		else if(auctionType = "Sealed")
		{
			write name + ' time to offer your money!!';
			do start_conversation (to: participants, protocol: 'fipa-propose', performative: 'cfp', contents: ['Bid For Sealed']);
		}
	}
	
	
	
    // Aspect to represent the Auctioneer visually
    aspect base {
    	if(auctionType= "English"){
			myColor<- #gold;
		}
		else if(auctionType= "Dutch"){
			myColor<- #gray;
		}
		else if(auctionType= "Sealed"){
			myColor<- #black;
		}
		draw triangle(6) color: myColor;
    }
   
}
 
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
