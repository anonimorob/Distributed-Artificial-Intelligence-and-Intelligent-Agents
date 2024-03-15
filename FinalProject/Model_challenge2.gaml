/**
* Name: Final Project
* Based on the internal empty template. 
* Author: Adele and Kat
* Tags: Party Environment
*/

// Main model definition
model PartyModel


// Global variables and initial settings
global {
    // Defining the number of agents for each type
    int numberOfDieHardFan <- 12;
    int numberOfCasualObserver <- 15;
    int numberOfSelfieAddict <- 16;
    int numberOfCritic <- 10;
    int numberOfSocialButterfly <- 18;
    
    int numberofBars <- 8;
    int numberofConcerts <- 4;
    
    //Global value to chart
    int totalInteractions <- 0;
    float totalHappinessDieHardFan <- 0.0;
    float totalHappinessCasualObserver <- 0.0;
    float totalHappinessSelfieAddict <- 0.0;
    float totalHappinessCritic <- 0.0;
    float totalHappinessSocialButterfly <- 0.0;

    // Lists to store all people and location points for concerts and bars
    list<Person> allPeople;
    list<point> ConcertPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];
    list<point> BarPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];

	float learning_rate <- 0.1;
    float discount_factor <- 0.9;
	    
    //to measure improvement
    float averageTimeToFindStage <- 0.0;
    int totalSuccesses <- 0;
    int totalAttempts <- 0;
    
    float totalCumulativeReward <- 0.0;    
    map<string, float> averageRewardPerAgentType ;
    map<string, int> successCountPerAgentType ;
    map<string, int> attemptCountPerAgentType ;
    map<string, float> averageTimeToGoalPerAgentType;
    
    list<string> agentTypes <- list("DieHardFan", "CasualObserver", "SelfieAddict", "Critic", "SocialButterfly");
    
    
    // Initialization block to create agents and set up the environment
    init {
    	// Creating different types of agents
        create Person number: 1 {}
        create DieHardFan number:numberOfDieHardFan{}
        create CasualObserver number:numberOfCasualObserver{}
        create SelfieAddict number:numberOfSelfieAddict{}
        create Critic number:numberOfCritic{}
        create SocialButterfly number:numberOfSocialButterfly{}

        // Creating places for interaction - bars and concerts
        create Bar number:numberofBars;
        create Concert number:numberofConcerts;

        // Setting up DieHardFan agents
        loop counter from: 1 to: numberOfDieHardFan {
            DieHardFan my_agent <- DieHardFan[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ DieHardFan[counter - 1];   
        }
        
        // Setting up CasualObserver agents
        loop counter from: 1 to: numberOfCasualObserver {
            CasualObserver my_agent <- CasualObserver[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ CasualObserver[counter - 1];   
        }
        
        // Setting up SelfieAddict agents
        loop counter from: 1 to: numberOfSelfieAddict {
            SelfieAddict my_agent <- SelfieAddict[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ SelfieAddict[counter - 1];   
        }
        
        // Setting up Critic agents
        loop counter from: 1 to: numberOfCritic {
            Critic my_agent <- Critic[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ Critic[counter - 1];   
        }
        
        //Setting up create SocialButterfly agents
        loop counter from: 1 to: numberOfSocialButterfly {
            SocialButterfly my_agent <- SocialButterfly[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ SocialButterfly[counter - 1];   
        }
        
        // Assigning locations to concerts
        loop counter from: 1 to: numberofConcerts {
            Concert my_agent <- Concert[counter - 1];
            my_agent <- my_agent.setName(counter);
            ConcertPoints[counter - 1] <- Concert[counter - 1].location;   
        }
        
        // Assigning locations to bars
        loop counter from: 1 to: numberofBars {
            Bar my_agent <- Bar[counter - 1];
            my_agent <- my_agent.setName(counter);
            BarPoints[counter - 1] <- Bar[counter - 1].location;   
        }
        
        // Use a while loop with an index to initialize your maps
		int i <- 0;
		loop while: (i < length(agentTypes)) {
		    string agentType <- agentTypes[i];
		    averageRewardPerAgentType[agentType] <- 0.0;
		    successCountPerAgentType[agentType] <- 0;
		    attemptCountPerAgentType[agentType] <- 0;
		    averageTimeToGoalPerAgentType[agentType] <- 0.0;
		    i <- i + 1;
		}
                  
    }
  
}


// Main class, parent of all others
species Person skills: [moving, fipa] control: simple_bdi {
    string personName <- "Undefined";
    
    // Action to set the name of the person
    action setName(int num) {
        personName <- ("Person" + num);
    }
    
    // Base aspect for drawing the agent
    aspect base {
        rgb agentColor <- rgb("gray");
        draw sphere(1) color: agentColor border: #black;
    }
  
    // Reflex to define the default movement behavior
    reflex beIdle {
        do wander;  
    }
    
}


species DieHardFan parent: Person{
	// Traits of a DieHardFan
	point favoriteConcertLocation <- ConcertPoints[rnd(0,numberofConcerts-1)]; 
	
    bool enthusiasm <- flip(0.2); 
    bool allegiance <- flip(0.8); 
    bool musicalRecognition <- flip(0.8); 
    point targetPoint <- nil;
    
    //to measure improvement
    int stepsTaken <- 0;
    float startTime <- 0.0;
    float timeToFindStage <- 0.0;
    bool isLookingForStage <- false;
    
    // To measure improvement
    float totalReward <- 0.0;
    float totalTimeToGoal <- 0.0;
    int goalCount <- 0;
    
    // Set name action
    action setName(int num) {
        personName <- ("Die-Hard Fan " + num);
    }
 
    // Aspect for drawing the agent
    aspect base {
        rgb agentColor <- rgb("red");
        draw sphere(2) color: agentColor;
    }
    
	list<int> states <- list(0, 1); // 0: wander, 1: look_for_stage, 2:at_stage
    list<int> actions <- list(0, 1, 2, 3); // 0: move_to_stage, 1: listen, 2:leave

    // Q-table as a map of state to action-values
    map<int, map<int, float>> q_table;

    int currentState <- 0; // Initial state (wander)
    int currentAction <- 0;
    float reward <- 0.0;

    // Initialize the Q-table with default values
    init {
        loop s over: states {
            map<int, float> actionValues;
            loop a over: actions {
                actionValues[a] <- 0.0; // Initialize Q-values to 0
            }
            q_table[s] <- actionValues;
        }
    }
    
   	// Reflex to update musicalRecognition randomly
    reflex update_recognition when: currentState = 0 and not musicalRecognition{
        musicalRecognition <- flip(0.2);
    }
    
    reflex wandering when:targetPoint = nil{
    	do wander;
    }
    
    // Reflex to start looking for a stage
    reflex start_looking_for_stage when: musicalRecognition {
        isLookingForStage <- true;
        startTime <- time; 
    }
    
    // If the fan recognizes the music, they have the desire to find the stage using the q-table
    // Reflex to make decisions based on Q-values and update the Q-table
    reflex look_for_stage when: musicalRecognition {
        map<int, float> currentActions <- q_table[currentState];
        int nextAction <- shuffle(currentActions.keys) with_max_of (currentActions[each]);
        int nextState <- (nextAction = 0) ? 1 : 0; // Assuming moving to stage changes state to at a stage
        
        // Reward logic
        reward <- nextAction = 1 ? 1.0 : 0.0; // Reward for listening to favorite music at a stage

        // Update the Q-value for the current state-action pair
        float current_Q_value <- currentActions[currentAction];
        float max_future_reward <- max(q_table[nextState].values);
        currentActions[currentAction] <- current_Q_value + learning_rate * (reward + discount_factor * max_future_reward - current_Q_value);

        // Update the state and action
        currentState <- nextState;
        currentAction <- nextAction;

        // Perform the chosen action
         if (not isLookingForStage) {
            timeToFindStage <- time - startTime; // Calculate the time taken to find the stage
            isLookingForStage <- false; // Stop looking for the stage
        }
        do movethere(currentAction);
    }
   	
	// Action to perform based on the chosen action
    action movethere(int a) {
	    if (a = 0) { // Move to the concert location
	    	
	    	targetPoint <- favoriteConcertLocation; 
	    	write name + " going to my fav location";
	        do goto target: targetPoint;
	    } else if (a = 1) { // Listen to the music
	        // Logic to listen to the music
	        //do wait(10.0); // Example: wait for 10 simulation time units
	        write name + " listening to music";
	        totalHappinessDieHardFan <- totalHappinessDieHardFan + 1;
	        musicalRecognition <- false; // Set musical recognition to false after listening
	        currentState <- 2; // Change state to 'leave'
	        targetPoint <- nil;
	    } else if (a = 2) { // Leave the concert
	     	write name + " leaving";
	        do wander; // Wander behavior
	        //totalHappinessDieHardFan <- totalHappinessDieHardFan - 1;
	        targetPoint <- nil;
	    }
    }
    
    // After the agent has reached a goal
    reflex update_metrics {//when: goal_achieved {
        goalCount <- goalCount + 1;
        totalReward <- totalReward + reward;
        totalTimeToGoal <- totalTimeToGoal + timeToFindStage;
        
        // Update the global metrics
        averageRewardPerAgentType["DieHardFan"] <- totalReward / goalCount;
        averageTimeToGoalPerAgentType["DieHardFan"] <- totalTimeToGoal / goalCount;
        successCountPerAgentType["DieHardFan"] <- successCountPerAgentType["DieHardFan"] + 1;
    }
    
    // When starting a new attempt to reach a goal
    reflex start_new_attempt {
        attemptCountPerAgentType["DieHardFan"] <- attemptCountPerAgentType["DieHardFan"] + 1;
        // Reset the local attempt metrics if necessary
    }		
}

species CasualObserver parent: Person {
    float reward <- 0.0;
    point targetBarLocation <- nil; // This will be assigned when the agent decides to go to a specific bar
    
    // Traits of a CasualObserver
    bool passionForMusic <- flip(0.5); 
    bool ingenuity <- flip(0.2); 
    bool boredness <- flip(0.4);
    
    bool isLookingForBar <- false;
    int stepsTaken <- 0;
    float startTime <- 0.0;
    float timeToFindBar <- 0.0;
    
    // To measure improvement
    float totalReward <- 0.0;
    float totalTimeToGoal <- 0.0;
    int goalCount <- 0;
    
    // Set name action
    action setName(int num) {
        personName <- ("CasualObserver " + num);
    }
 
    // Aspect for drawing the agent
    aspect base {
        rgb agentColor <- rgb("hotpink");
        draw pyramid(float(5,5,5)) color: agentColor;
    }
    
     // Reflex for CasualObserver to interact with Critic agents
    reflex sendquestiontoCritics when: ingenuity{
      	do start_conversation to: list(Critic) protocol: 'no-protocol' performative: 'inform' contents: ['I am a Casual Observer, could anyone of the Critical people tell me where I am ?'];
        write '(Time ' + time + '): ' + name + ' sent a private message to Critic Agent.';
        do start_conversation to: list(list(Critic)[0], list(Critic)[1]) protocol: 'no-protocol' performative: 'inform' contents: ['Critic person,  you are receiving a msg!'];
        write "I am a Casual Observer, could you tell me where I am ?";
        write '-----------------------------------------------------';
        
		totalInteractions <- totalInteractions + 1;
    }
    
    // Q-table as a map of state to action-values for the CasualObserver  
    list<int> states <- list(0,1,2); //"Wandering", "SearchingForBar", "AtBar");
    list<int> actions <- list(0,1,2,3,4);//"WanderRandomly","MoveTowardsBar", "OrderDrink", "StartConversation", "LeaveBar");   
    map<int, map<int, float>> q_table;
    
    int currentState <- 0; // Initial state
    int currentAction <- 0;

    // Initialize the Q-table with default values
    init {
        loop s over: states {
            map<int, float> actionValues;
            loop a over: actions {
                actionValues[a] <- 0.0; // Initialize Q-values to 0
            }
            q_table[s] <- actionValues;
        }
    }
    
    // Reflex to start looking for a bar
    reflex look_for_bar when:boredness{
        // Similar logic to DieHardFan for choosing actions based on Q-values
        map<int, float> currentActions <- q_table[currentState];
        int nextAction <- shuffle(currentActions.keys) with_max_of (currentActions[each]);
        int nextState <- (nextAction = 1) ? 1 : 0; // Assuming MoveTowardsBar changes state to SearchingForBar
        
        // Reward logic
        reward <- (currentState = 2 and nextAction = 3) ? 1.0 : 0.0; // Reward for startConversation at bar
        reward <- (currentState = 1 and (nextAction=4 or nextAction=0) ) ? -1.0 : 0.0; // Neg Reward for leaving bar after searching

        // Update the Q-value for the current state-action pair
        float current_Q_value <- currentActions[currentAction];
        float max_future_reward <- max(q_table[nextState].values);
        currentActions[currentAction] <- current_Q_value + learning_rate * (reward + discount_factor * max_future_reward - current_Q_value);

        // Update the state and action
        currentState <- nextState;
        currentAction <- nextAction;
        
        targetBarLocation <- (BarPoints with_min_of (each distance_to self)).location;
        

        do movetoBar(currentAction);
    }
    
    // Action to perform based on the chosen action
    action movetoBar(int a) {
    	if(a =0 or a = 4){ //wander or leave
    		do wander;
    		//totalHappinessCasualObserver <- totalHappinessCasualObserver - 1; 
    	} else if (a =1 and targetBarLocation !=nil){ //move 
    		do goto target: targetBarLocation;
    	} else if ( a =2){//order drink
    		if (targetBarLocation = self.location){
    			write name+" drank at a bar";
    			totalHappinessCasualObserver <- totalHappinessCasualObserver + 1; 
    		}	
    	} else if (a =3){//converse
    		do start_conversation to: list(Critic) protocol: 'no-protocol' performative: 'inform' contents: ['I am a Casual Observer, could anyone of the Critical people tell me where I am ?'];
	       	write "I am a Casual Observer, could you tell me where I am ?";
	        write '-----------------------------------------------------';
	        totalHappinessCasualObserver <- totalHappinessCasualObserver + 1; 
	   	}
    }
    
        
    // Perception to find a bar with drinks
    perceive target: Bar where (each.hasDrink = true and isLookingForBar) {
        write myself.personName + " drank at Bar  " + self.BarName;
        totalHappinessCasualObserver <- totalHappinessCasualObserver + 1; 
        myself.isLookingForBar <- false;
    }
    
}


species SelfieAddict parent: Person{
		
		bool instaCredibility <- flip (0.5); 
		bool attentionSeeking <- flip(0.8); 
		bool senseOfStyle <- flip (0.8); 
		
		point targetPoint <- nil;
		list randomPerson;
		agent closestPerson ;
		point place <- nil;
		
		//BDI strings and predicates
		string foundStageWithMusicString <- "I understood from which stage comes the music";
    	predicate foundStageWithMusic <- new_predicate(foundStageWithMusicString);
	
		string lookingForSelfieString <- "Looking for a concert to take a Selfie!";
    	predicate lookingForSelfie <- new_predicate(lookingForSelfieString);
    
    	string takeSelfieNearConcertString <- "I really want to take a selfie near this concert";
    	predicate takeSelfieNearConcert <- new_predicate(takeSelfieNearConcertString);
    
		action setName(int num) {
            	personName <- ("SelfieAddict " + num);
        }
         
        aspect base{
        rgb agentColor <- rgb("yellow");
        draw sphere(3) color: agentColor;
    }
    
    //RULE on how interacts with near people
    
    //if the agent is near a Bar, and its sense of style is high, he will ask someone to take him a photo
	reflex askForPhotoAtBar {
		targetPoint <- BarPoints closest_to self.location;
			if senseOfStyle{
				do goto target: targetPoint;
				do lookForSomeoneToTakePhoto;
				totalInteractions <- totalInteractions + 1; 
		} 
	}

	action lookForSomeoneToTakePhoto {

    // Find a person in the vicinity
    	loop item over: allPeople {  
    		if (item.location distance_to self.location) < 1 {
    		// Ask them to take a photo
    			ask item  {
    				write "I am a Selfie Addict, can you take a photo of me near this bar?" ; 
    				totalHappinessSelfieAddict <- totalHappinessSelfieAddict + 0.25;
    				
    			}
    			break;
    		} else {
    			//totalHappinessSelfieAddict <- totalHappinessSelfieAddict - 0.25;
    		}   	
    }  	
    //post the photo on the social media
      	  do postOnSocialMedia("Love the music here!");
    }

	action postOnSocialMedia(string caption) {
    // Simulate posting a selfie to social media
   	 write( personName + " has posted a photo of themselves at the concert with the caption: " + caption);
   	 totalHappinessSelfieAddict <- totalHappinessSelfieAddict + 1;
}
    
    
   //BDI CONTROL: If the agent attentionseeking, he will move to the stage from which he hears the music
    init {
		if (attentionSeeking) {
        	do add_desire(lookingForSelfie);
        }
    }      	
    // Plan for achieving the 'lookForStage' intention 
	plan doWandering intention: lookingForSelfie {
		totalHappinessSelfieAddict <- totalHappinessSelfieAddict - 1;
		do wander;
	}
	
	rule belief: foundStageWithMusic new_desire: takeSelfieNearConcert strength: 2.0;	
	
	   plan takeSelfieNearConcert intention: takeSelfieNearConcert {
	   	//write "takeSelfieNearConcert!!!!!!!!!!!!";
	 	list<point> candidateStages <- get_beliefs_with_name(foundStageWithMusicString) collect (point(get_predicate(mental_state (each)).values["location_value"]));
	 	point target <- (candidateStages with_min_of (each distance_to self)).location;
	    
	    do goto target: target; 
	    	
	 	 if (target = self.location and senseOfStyle = true) {
			 	
			 	do takePicture();
			 	
	    		do remove_belief(foundStageWithMusic);
	    		// Or, instead of the two following lines, we can write: do remove_intention(moveToStage, true).
	    		do remove_desire(takeSelfieNearConcert);
	    		do remove_intention(takeSelfieNearConcert);
	    		
	    		}
	    	}
    	
    	
   perceive target: Concert where (each.hasMusic = true and self.attentionSeeking ) {
        focus id:myself.foundStageWithMusicString var:location;
        ask myself {
            do remove_intention(lookingForSelfie, true);
        }
    }
    
  
    	
 action takePicture {
    // Take a selfie with your phone
    write "I just took a fantastic selfie";
    totalHappinessSelfieAddict <- totalHappinessSelfieAddict + 1;
    }
    
}


species Critic parent: Person{
	
		bool musicalExpertize <- flip(0.2); 
		bool verbalAssertiveness <- flip(0.4); 
		bool openMindness <- flip(0.4);  
		
				
		action setName(int num) {
            	personName <- ("Critic  " + num);
            }
        aspect base{
        rgb agentColor <- rgb("blue");
        draw box(3, 5, 2) color: agentColor;
    	}
    
    reflex recieveQuestionFromCasualObserver when: !empty(informs) {
		int numberOfMsgs <- length(informs);
		
		if verbalAssertiveness and openMindness{
		
		//  read the content of the message.

		loop informMsg over: informs {
			string recievedContent <- informMsg.contents;
			do end_conversation message: informMsg contents: ['End!'];
		}	
		write 'We are at a concert, and now I will give you my feedback about it.... ';
		write '-----------------------------------------------------';	
		totalInteractions <- totalInteractions + 1; 
		totalHappinessCritic <- totalHappinessCritic + 1;			
	   }else{
	   	totalHappinessCritic <- totalHappinessCritic - 0.5;	
	   }
	}
	
	//Critic people will be happier (set a value of happiness) if they interact with people at a concert and not when they interact in a bar
	reflex criticizeTheConcert{
		if location distance_to one_of(Concert) < 0.5 {
			if openMindness{
				do lookForSomeoneToCriticize;
				totalInteractions <- totalInteractions + 1; 	
			}
		}else{
			do wander;
			totalHappinessCritic <- totalHappinessCritic - 0.5;
		}
	
		if location distance_to one_of(Bar) < 0.5 {
			//Lower Happiness when they criticize at bar
			if verbalAssertiveness and openMindness{
				totalHappinessCritic <- totalHappinessCritic + 0.5;
			}else{
				//They don't want to criticize but can't find a bar nearby
				totalHappinessCritic <- totalHappinessCritic - 0.5;
			}
				
		}
	
	}
	action lookForSomeoneToCriticize {

    // Find a person in the vicinity
    	loop item over: allPeople {  
    		if (item.location distance_to self.location) < 0.5 {
    			
    		// Tell them what you think about the concert if you are happy
    			ask item  {
    				//High Happiness??
					totalHappinessCritic <- totalHappinessCritic + 2;
    				write "What do you think about this concert?" ;
    				break; 
    			}
    			
    	}   	
    }  	

    } 
    
}


species SocialButterfly parent: Person {
    
    bool introversion <- flip(0.2);
    bool curiosity <- flip(0.8);
    bool talkativeness <- flip(0.8);
    point targetPoint <- nil;
    
    // BDI elements for SocialButterfly
    string lookingForInteractionString <- "Looking for someone to interact with";
    predicate lookingForInteraction <- new_predicate(lookingForInteractionString);
    
    string foundInteractionString <- "Found a potential interaction";
    predicate foundInteraction <- new_predicate(foundInteractionString);
    
    string socializingString <- "Engaging in socialization";
    predicate socializing <- new_predicate(socializingString);
    
    action setName(int num) {
        personName <- ("Social Butterfly " + num);
    }
	aspect base {
        rgb agentColor <- rgb("orange");
        draw box(3, 3, 3) color: agentColor border: #black;
    }
    
    init {
        if (curiosity and not introversion) {
            do add_desire(lookingForInteraction);
        }
    }
    
        
    reflex justStrolling when: targetPoint = nil {
    	do wander;
    	if talkativeness {
    		//they are feeling talkative, but cannot find interaction
    		totalHappinessSocialButterfly <- totalHappinessSocialButterfly - 0.5;
    	}
    }
    
    reflex lookingForInteraction when: (curiosity and not introversion and has_desire_with_name_op(self,"lookingForInteractionString")) {
        targetPoint <- one_of(ConcertPoints closest_to self.location);
        if (targetPoint != nil) {
            do add_belief(foundInteraction);
            do remove_desire(lookingForInteraction);
            do add_desire(socializing);
        }
    }
    
    reflex start_conversation when: talkativeness and not introversion {
        loop person over: allPeople {
            if (person != self and person.location distance_to self.location < 1) {
                do start_conversation to: list(person) protocol: 'fipa-propose' performative: 'cfp' contents: ['I am a SocialButterfly, could anyone tell me where I am ?'];
            	write '(Time ' + time + '): ' + name + ' sent a private message to Person Agent.';
            	write "I am a SocialButterfly, how are you enjoying the party?";
            	write '-----------------------------------------------------';
            	totalInteractions <- totalInteractions + 1; 
            	totalHappinessSocialButterfly <- totalHappinessSocialButterfly + 1;
                
            }
        }
    }
    
    plan moveToInteraction intention: socializing {
    	write name+" going to interact and socialize";
    	do goto target: targetPoint;
        do remove_belief(foundInteraction);
    }
    
    plan socialize intention: socializing {
        list<point> potentialInteractions <- get_beliefs_with_name(foundInteractionString) collect (point(get_predicate(mental_state(each)).values["location_value"]));
        if (potentialInteractions != nil) {
            point interactionLocation <- potentialInteractions[0];
            do goto target: interactionLocation;
            
            // Interaction logic: start a conversation with the nearest person
            agent closestPerson <- one_of(allPeople closest_to self.location);
            if (closestPerson != nil and closestPerson != self) {
                do start_conversation to: list(closestPerson) protocol: 'fipa-request' performative: 'request' contents: ['Hi, I am a Social Butterfly. Can we chat?'];
                write name + " socizaling at the concert :)";
            	write '-----------------------------------------------------';
            	totalInteractions <- totalInteractions + 1; 
            	totalHappinessSocialButterfly <- totalHappinessSocialButterfly + 2;
                do remove_desire(socializing); // Socialization desire fulfilled
                           
            }
        }
    }
    
    // Perception to update the list of potential interactions
    perceive target: Concert where (each.hasMusic = true and each.isCrowded = true) {
        focus id: myself.socializingString var: location;
        ask myself {
            do remove_intention(lookingForInteraction, true);
        }
    }
}

species Bar{
	string BarName <- "Undefined";
	bool hasDrink <- flip(0.5);
	
    action setName(int num) {
		BarName <- "Bar " + num;
	}  
	
	aspect default{
		rgb barColor <- rgb("darkred"); 
		draw (box(5,5,5)) at: location color: barColor;   
	}
}

species Concert{
	string ConcertName <- "Undefined";
	
	bool hasMusic <- flip(0.5);
	bool isCrowded <- flip(0.5);
	
	action setName(int num) {
		ConcertName <- "Concert " + num;
	} 
	
	aspect default{
		rgb ConcertColor <- rgb("darkgreen"); 
		draw (cylinder(4, 10)) at: location color: ConcertColor;   
	}
}


experiment main type: gui{
	output {
		display map type: opengl {
			species DieHardFan aspect: base;
			species CasualObserver aspect: base;
			species SelfieAddict aspect: base;
			species Critic aspect: base;
			species SocialButterfly aspect: base;
			species Bar aspect:default;
			species Concert aspect:default;
			
			/* Add a chart for evaluation metrics
	        chart "Evaluation Metrics" type: series {
	            data "Average Reward DieHardFan" value: averageRewardPerAgentType["DieHardFan"] color: #red;
	            data "Average Time To Goal DieHardFan" value: averageTimeToGoalPerAgentType["DieHardFan"] color: #blue;
	            // ... Add lines for other metrics and agent types ...
	    	}
	    	
	    	chart "Happiness Metrics" type: series {
	            data "Happiness DieHardFan" value: totalHappinessDieHardFan color: #red;
	            //data "Happiness CasualObserver" value: totalHappinessCasualObserver color: #pink; 
	            data "Happiness SelfieAddict" value: totalHappinessSelfieAddict color: #yellow; 
	            data "Happiness Critic" value: totalHappinessCritic color: #blue;
	            data "Happiness SocialButterfly" value: totalHappinessSocialButterfly color: #orange; 
	        }*/
        }
	        // Monitor for global cumulative reward
	        monitor "Total Cumulative Reward" value: totalCumulativeReward;
	        // ... Additional monitors for success counts, attempt counts, etc. ...
	        		
	}
}

