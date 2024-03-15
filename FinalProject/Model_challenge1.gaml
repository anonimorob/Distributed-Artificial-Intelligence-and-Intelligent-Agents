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

    // Lists to store all people and location points for concerts and bars
    list<Person> allPeople;
    list<point> ConcertPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];
    list<point> BarPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];
    
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

// Species for DieHardFan
species DieHardFan parent: Person {
    // Traits of a DieHardFan
    bool enthusiasm <- flip(0.2); 
    bool allegiance <- flip(0.8); 
    bool musicalRecognition <- flip(0.8); 
    point targetPoint <- nil;

    // BDI elements (beliefs, desires, intentions)
    string foundStageWithMusicString <- "I understood from which stage comes the music";
    predicate foundStageWithMusic <- new_predicate(foundStageWithMusicString);
    string lookingForStageString <- "Looking for the Stage from which I hear that music";
    predicate lookingForStage <- new_predicate(lookingForStageString);
    string moveToStageString <- "Moving to that stage";
    predicate moveToStage <- new_predicate(moveToStageString);
    
    // Set name action
    action setName(int num) {
        personName <- ("Die-Hard Fan " + num);
    }
 
    // Aspect for drawing the agent
    aspect base {
        rgb agentColor <- rgb("red");
        draw sphere(2) color: agentColor;
    }

    // Reflex to interact with nearby agents based on enthusiasm
    reflex checkNearbyAgents {
        if enthusiasm {
            loop item over: allPeople { 
                if (item.location distance_to self.location) < 1 {
                    ask item {
                        write "Hey, are you enjoying this concert too? I am a DieHardFan and I love this music!" ; 
                    }
                }   
            }  
        }
        //do updateInteractions(); // Update the global interaction count
        totalInteractions <- totalInteractions + 1; 
    }

    // BDI Control for DieHardFan agents
    init {
        // If the fan recognizes the music, they have the desire to find the stage
        if (musicalRecognition) {
            do add_desire(lookingForStage);
        }
    }

    // Plan for DieHardFan to achieve the 'lookingForStage' intention
    plan doWandering intention: lookingForStage {
        do wander; // Wandering behavior to look for the stage
    }
    
    // Perception for DieHardFan to find concert with music
    perceive target: Concert where (each.hasMusic = true and self.enthusiasm) {
        focus id: myself.foundStageWithMusicString var: location;
        ask myself {
            do remove_intention(lookingForStage, true);
        }
    }

    // Rule for DieHardFan to transition from belief to desire
    rule belief: foundStageWithMusic new_desire: moveToStage strength: 2.0;

    // Plan for DieHardFan to move to the stage
    plan moveToStage intention: moveToStage {
        list<point> candidateStages <- get_beliefs_with_name(foundStageWithMusicString) collect (point(get_predicate(mental_state (each)).values["location_value"]));
        point target <- (candidateStages with_min_of (each distance_to self)).location;

        do goto target: target;

        if (target = self.location and allegiance = true) {
            write "I am a DieHardFan and I think that this music is awesome!!";
            do remove_belief(foundStageWithMusic);
            do remove_desire(moveToStage);
            do remove_intention(moveToStage);
        }
    }

    
}

// Species for CasualObserver
species CasualObserver parent: Person {
    // Traits of a CasualObserver
    bool passionForMusic <- flip(0.5); 
    bool ingenuity <- flip(0.2); 
    bool boredness <- flip(0.4);

    // BDI elements for CasualObserver
    string lookingForBarString <- "I am quite bored, I am looking for a Bar!";
    predicate lookingForBar <- new_predicate(lookingForBarString);
    string foundBarString <- "I understood where I can go";
    predicate foundBar <- new_predicate(foundBarString);
    string takeDrinkAtBarString <- "I am taking a drink at a Bar";
    predicate takeDrinkAtBar <- new_predicate(takeDrinkAtBarString);

    // Set name action for CasualObserver
    action setName(int num) {
        personName <- ("CasualObserver " + num);
    }

    // Aspect for drawing the CasualObserver
    aspect base {
        rgb agentColor <- rgb("hotpink");
        draw pyramid(float(5,5,5)) color: agentColor;
    }

    // Reflex for CasualObserver to interact with Critic agents
    reflex sendquestiontoCritics {
        if ingenuity {
            do start_conversation to: list(Critic) protocol: 'no-protocol' performative: 'inform' contents: ['I am a Casual Observer, could anyone of the Critical people tell me where I am ?'];
            write '(Time ' + time + '): ' + name + ' sent a private message to Critic Agent.';
            do start_conversation to: list(list(Critic)[0], list(Critic)[1]) protocol: 'no-protocol' performative: 'inform' contents: ['Critic person,  you are receiving a msg!'];
            write "I am a Casual Observer, could you tell me where I am ?";
            write '-----------------------------------------------------';
            
            totalInteractions <- totalInteractions + 1;
        }
    }

    // BDI Control for CasualObserver
    init {
        // If no passion for music, CasualObserver looks for a bar
        if (not passionForMusic) {
            do add_desire(lookingForBar);
        }
    }

    // Plan for CasualObserver to achieve the 'lookingForBar' intention
    plan doWandering intention: lookingForBar {
        do wander; // Wandering behavior to look for a bar
    }

    // Rule for CasualObserver to transition from belief to desire
    rule belief: foundBar new_desire: takeDrinkAtBar strength: 6.0;

    // Plan for CasualObserver to take a drink at a bar
    plan takeDrinkAtBar intention: takeDrinkAtBar {
        list<point> candidateBars <- get_beliefs_with_name(foundBarString) collect (point(get_predicate(mental_state (each)).values["location_value"]));
        point target <- (candidateBars with_min_of (each distance_to self)).location;

        do goto target: target;

        if (target = self.location) {
            Bar nearBar <- Bar(target);
            do askAdrink(nearBar);
            totalInteractions <- totalInteractions + 1;
            do remove_belief(foundBar);
            do remove_desire(takeDrinkAtBar);
            do remove_intention(takeDrinkAtBar);
        }
    }

    // Perception for CasualObserver to find a bar with drinks
    perceive target: Bar where (each.hasDrink = true and boredness) {
        focus id: myself.foundBarString var: location;
        ask myself {
            do remove_intention(lookingForBar, true);
        }
    }

    // Action for CasualObserver to ask for a drink at a bar
    action askAdrink(Bar nearBar) {
        ask nearBar {
            if self.hasDrink = true {
                write myself.personName + " drank at Bar  " + self.BarName;
            }
        }
    }
}

// Species for SelfieAddict
species SelfieAddict parent: Person {
    // Traits of a SelfieAddict
    bool instaCredibility <- flip(0.5); 
    bool attentionSeeking <- flip(0.8); 
    bool senseOfStyle <- flip(0.8);

    point targetPoint <- nil;
    list randomPerson;
    agent closestPerson;
    point place <- nil;

    // BDI elements for SelfieAddict
    string foundStageWithMusicString <- "I understood from which stage comes the music";
    predicate foundStageWithMusic <- new_predicate(foundStageWithMusicString);
    string lookingForSelfieString <- "Looking for a concert to take a Selfie!";
    predicate lookingForSelfie <- new_predicate(lookingForSelfieString);
    string takeSelfieNearConcertString <- "I really want to take a selfie near this concert";
    predicate takeSelfieNearConcert <- new_predicate(takeSelfieNearConcertString);

    // Set name action for SelfieAddict
    action setName(int num) {
        personName <- ("SelfieAddict " + num);
    }

    // Aspect for drawing the SelfieAddict
    aspect base {
        rgb agentColor <- rgb("yellow");
        draw sphere(3) color: agentColor;
    }

    // Reflex for SelfieAddict to interact with agents at a bar
    reflex askForPhotoAtBar {
        targetPoint <- BarPoints closest_to self.location;
        if senseOfStyle {
            do goto target: targetPoint;
                        // If the agent has a sense of style, it seeks to take a photo at the bar
            do lookForSomeoneToTakePhoto;
        } 
        //do updateInteractions(); // Update the global interaction count
        totalInteractions <- totalInteractions + 1;
    }

    // Action to find someone nearby to take a photo
    action lookForSomeoneToTakePhoto {
        // Find a person in proximity
        loop item over: allPeople {  
            if (item.location distance_to self.location) < 1 {
                // Request them to take a photo
                ask item {
                    write "I am a Selfie Addict, can you take a photo of me near this bar?" ; 
                }
            }
        }   
        // Simulate posting the photo on social media
        do postOnSocialMedia("Love the music here!");
    }

    // Action to simulate posting a photo on social media
    action postOnSocialMedia(string caption) {
        write( personName + " has posted a photo of themselves at the concert with the caption: " + caption);
    }
    
    // BDI Control: If the agent seeks attention, it will move towards the stage to take a selfie
    init {
        if (attentionSeeking) {
            do add_desire(lookingForSelfie); // Desire to find a concert for a selfie
        }
    }

    // Plan for achieving the 'lookForStage' intention
    plan doWandering intention: lookingForSelfie {
        do wander; // The agent wanders to look for a concert stage.
    }

    // Rule to create a new desire based on the found stage with music
    rule belief: foundStageWithMusic new_desire: takeSelfieNearConcert strength: 2.0; 

    // Plan to take a selfie near the concert
    plan takeSelfieNearConcert intention: takeSelfieNearConcert {
        list<point> candidateStages <- get_beliefs_with_name(foundStageWithMusicString) collect (point(get_predicate(mental_state (each)).values["location_value"]));
        point target <- (candidateStages with_min_of (each distance_to self)).location;
        
        do goto target: target; // Move to the target location

        if (target = self.location and senseOfStyle = true) {
            do takePicture(); // Take a selfie if at the target location and has a sense of style
            
            // Remove beliefs and desires after taking a selfie
            do remove_belief(foundStageWithMusic);
            do remove_desire(takeSelfieNearConcert);
            do remove_intention(takeSelfieNearConcert);
        }
    }

    // Perceive a concert where there is music and the agent seeks attention
    perceive target: Concert where (each.hasMusic = true and self.attentionSeeking) {
        focus id:myself.foundStageWithMusicString var:location;
        ask myself {
            do remove_intention(lookingForSelfie, true);
        }
    }

    // Action to simulate taking a picture
    action takePicture {
        write "I just took a fantastic selfie";
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
		   }
		}
	
		//Critic people will be happier (set a value of happiness) if they interact with people at a concert and not when they interact in a bar
		reflex criticizeTheConcert{
			if location distance_to one_of(Concert) < 0.5 {
				if openMindness{
					do lookForSomeoneToCriticize;
				}
			}
			
			if location distance_to one_of(Bar) < 0.5 {
				//Lower Happiness
			}
			
			//do updateInteractions(); // Update the global interaction count
			totalInteractions <- totalInteractions + 1;
		}
	
		action lookForSomeoneToCriticize {
			// Find a person in the vicinity
    		loop item over: allPeople {  
    			if (item.location distance_to self.location) < 0.5 {
    				// Tell them what you think about the concert if you are happy
    				ask item  {
    					//High Happiness??
    					write "What do you think about this concert?" ; 
    				}
    			}   	
    		}  	
	    }     
}


// Species for SocialButterfly
species SocialButterfly parent: Person {
    // Traits of a SocialButterfly
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
    
    // Set name action
    action setName(int num) {
        personName <- ("Social Butterfly " + num);
    }
    
    // Aspect for drawing the agent
    aspect base {
        rgb agentColor <- rgb("orange");
        draw box(3, 3, 3) color: agentColor border: #black;
    }
    
    // Initialize the BDI elements
    init {
        if (curiosity and not introversion) {
            do add_desire(lookingForInteraction);
        }
    }
    
    // Reflex for looking for interaction based on talkativeness and not being introverted
    reflex lookingForInteraction when: (curiosity and not introversion and has_desire_with_name_op(self,"lookingForInteractionString")) {
        targetPoint <- one_of(ConcertPoints closest_to self.location);
        if (targetPoint != nil) {
            do add_belief(foundInteraction);
            do remove_desire(lookingForInteraction);
            do add_desire(socializing);
        }
    }
    
    // Reflex to interact based on talkativeness with the nearest agent
    reflex start_conversation when: talkativeness and not introversion {
        loop person over: allPeople {
            if (person != self and person.location distance_to self.location < 1) {
                // Start conversation logic
                do start_conversation to: list(person) protocol: 'fipa-propose' performative: 'cfp' contents: ['I am a SocialButterfly, could anyone tell me where I am ?'];
            	write '(Time ' + time + '): ' + name + ' sent a private message to Person Agent.';
            	//do start_conversation to: person protocol: 'no-protocol' performative: 'inform' contents: ['SocialButterfly person,  you are receiving a msg!'];
            	write "I am a SocialButterfly, how are you enjoying the party?";
            	write '-----------------------------------------------------';
                break; // Exit the loop once someone is found
            }
        }
        // Update interaction count
        totalInteractions <- totalInteractions + 1;
    }
    
    // Plan for moving to the interaction point and socializing
    plan moveToInteraction intention: socializing {
    	write name+" going to interact and socialize";
    	do goto target: targetPoint;
        do remove_belief(foundInteraction);
    }
    
    // Plan for socializing at the interaction point
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
                do remove_desire(socializing); // Socialization desire fulfilled
                
                totalInteractions <- totalInteractions + 1;               
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
			
			// Define a dynamic chart for total interactions over time
	        chart "Interactions Chart" type: series{
	            // Specify the type of chart and the data to display
	            data "Total Interactions" value: totalInteractions color: #red;	            
	        }
		}
		
		monitor "Total Interactions" value: totalInteractions;
				
	}
}
            
    
