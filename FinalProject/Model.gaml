/**
* Name: Final Project
* Based on the internal empty template. 
* Author: Adele and Kat
* Tags: Party Environment
*/





model PartyModel


global {
    int numberOfDieHardFan <- 12;
    int numberOfCasualObserver <- 15;
    int numberOfSelfieAddict <- 16;
    int numberOfCritic <- 10;
    int numberOfSocialButterfly <- 18;
    int numberofBars <- 8;
    int numberofConcerts <- 4;
    list<Person> allPeople;
	list<point> ConcertPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];
	list<point> BarPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];
    
    //Global value to chart
    int totalInteractions <- 0;
    float totalHappinessDieHardFan <- 0.0;
    float totalHappinessCasualObserver <- 0.0;
    float totalHappinessSelfieAddict <- 0.0;
    float totalHappinessCritic <- 0.0;
    float totalHappinessSocialButterfly <- 0.0;
    
   
    init {
    	
    	create Person number: 1 {}
        create DieHardFan number:numberOfDieHardFan{}
        create CasualObserver number:numberOfCasualObserver{}
        create SelfieAddict number:numberOfSelfieAddict{}
        create Critic number:numberOfCritic{}
        create SocialButterfly number:numberOfSocialButterfly{}
        create Bar number:numberofBars;
        create Concert number:numberofConcerts;


        loop counter from: 1 to: numberOfDieHardFan {
        	DieHardFan my_agent <- DieHardFan[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	allPeople <+ DieHardFan[counter - 1];   
        	//write "The Location of the DieHardFan is " + DieHardFan[counter - 1].location +"!!!";
        }
        
     
         loop counter from: 1 to: numberOfCasualObserver {
        	CasualObserver my_agent <- CasualObserver[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	allPeople <+ CasualObserver[counter - 1];   
        	//write "The Location of the CasualObserver is " + CasualObserver[counter - 1].location +"!!!";
        }
        
        
         loop counter from: 1 to: numberOfSelfieAddict {
        	SelfieAddict my_agent <- SelfieAddict[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	allPeople <+ SelfieAddict[counter - 1];   
        	//write "The Location of the SelfieAddict is " + SelfieAddict[counter - 1].location +"!!!";
        }
        
        
        loop counter from: 1 to: numberOfCritic {
        	Critic my_agent <- Critic[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	allPeople <+ Critic[counter - 1];   
        	//write "The Location of the Critic is " + Critic[counter - 1].location +"!!!";
        }
        
        loop counter from: 1 to: numberOfSocialButterfly {
            SocialButterfly my_agent <- SocialButterfly[counter - 1];
            my_agent <- my_agent.setName(counter);
            allPeople <+ SocialButterfly[counter - 1];   
        }
        
        
        loop counter from: 1 to: numberofConcerts {
        	Concert my_agent <- Concert[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	ConcertPoints[counter - 1] <- Concert[counter - 1].location;   
        	//write "The Concert Location is " + Concert[counter - 1].location +"!!!";
        }
        
        
        loop counter from: 1 to: numberofBars {
        	Bar my_agent <- Bar[counter - 1];
        	my_agent <- my_agent.setName(counter);
        	BarPoints[counter - 1] <- Bar[counter - 1].location;   
        	//write "The Bar Location is " + Bar[counter - 1].location +"!!!";
        }
    }
}


//Main Class, parent of all the others. It gives to the other species the skills and the type of control
species Person skills: [moving, fipa] control: simple_bdi{
	string personName <- "Undefined";
		 
	action setName(int num) {
    	personName <- ("Person" + num);
    }
            	
    aspect base{
    	rgb agentColor <- rgb("gray");
        draw sphere(1) color: agentColor border: #black;
	} 
  
     
 	// Define the moving reflex
    reflex beIdle{
    	do wander;  
    }
    
}
    

species DieHardFan parent: Person{
	
	bool enthusiasm <- flip(0.2); 
	bool allegiance <- flip(0.8); 
	bool musicalRecognition <- flip(0.8); 
	   
    point targetPoint <- nil;


// BDI strings and predicates
	string foundStageWithMusicString <- "I understood from which stage comes the music";
    predicate foundStageWithMusic <- new_predicate(foundStageWithMusicString);
	
	string lookingForStageString <- "Looking for the Stage from which I hear that music";
    predicate lookingForStage <- new_predicate(lookingForStageString);
    
    string moveToStageString <- "Moving to that stage";
    predicate moveToStage <- new_predicate(moveToStageString);
    
    
   action setName(int num) {
            	personName <- ("Die-Hard Fan " + num);
            }
 
   aspect base{
       		rgb agentColor <- rgb("red");
           	draw sphere(2) color: agentColor;
           }
  
                 	
 // RULE how to interact with near people: If the enthusiasm is high, they will talk with near people
 reflex checkNearbyAgents {
    	if enthusiasm{
    		loop item over: allPeople { 
    			if (item.location distance_to self.location) < 1 {
    			
    			ask item  {
    				write "Hey, are you enjoying this concert too? I am a DieHardFan and I love this music!" ; 
    				totalHappinessDieHardFan <- totalHappinessDieHardFan + 1;
    	     	}
    	    }   	
          } 
          totalInteractions <- totalInteractions + 1;  
    	}
}
  
    
    
 //BDI CONTROL: If the agent recognizes the song, he will have the desire to move to the stage from which he hears the music
    init {
		if (musicalRecognition) {
        	do add_desire(lookingForStage);
        }
    }  
        	
    // Plan for achieving the 'lookForStage' intention 
	plan doWandering intention: lookingForStage {
		totalHappinessDieHardFan <- totalHappinessDieHardFan - 1;
		do wander;
	}
	
	
rule belief: foundStageWithMusic new_desire: moveToStage strength: 2.0;	

   plan moveToStage intention: moveToStage {

 	list<point> candidateStages <- get_beliefs_with_name(foundStageWithMusicString) collect (point(get_predicate(mental_state (each)).values["location_value"]));
 	point target <- (candidateStages with_min_of (each distance_to self)).location;
    
    do goto target: target; 
    	
 	 if (target = self.location and allegiance = true) {
		 	
		 write "I am a DieHardFan and I think that this music is awesome!!";
		 totalHappinessDieHardFan <- totalHappinessDieHardFan +1;
		 totalInteractions <- totalInteractions + 1; 
		 
    		do remove_belief(foundStageWithMusic);
    		
    		do remove_desire(moveToStage);
    		do remove_intention(moveToStage);
    		
    		}
    	}
    	
    	
   perceive target: Concert where (each.hasMusic = true and self.enthusiasm ) {
        focus id:myself.foundStageWithMusicString var:location;
        ask myself {
            do remove_intention(lookingForStage, true);
        }
    }
    
   }
   
   
   
species CasualObserver parent: Person{
	
		bool passionForMusic <- flip(0.5); 
		bool ingenuity <- flip(0.2); 
		bool boredness <- flip(0.4); 
			

// BDI strings and predicates
		string foundBarString <- "I understood where I can go";
    	predicate foundBar <- new_predicate(foundBarString);
	
		string lookingForBarString <- "I am quite bored, I am looking for a Bar!";
    	predicate lookingForBar <- new_predicate(lookingForBarString);
    
    	string takeDrinkAtBarString <- "I am taking a drink at a Bar";
    	predicate takeDrinkAtBar <- new_predicate(takeDrinkAtBarString);
		
		
		action setName(int num) {
            	personName <- ("CasualObserver  " + num);
            } 
                       
        aspect base{
        rgb agentColor <- rgb("hotpink");
        draw pyramid(float(5,5,5)) color: agentColor;
    }
    
    reflex boredAtConcert when: boredness{
    	totalHappinessCasualObserver <- totalHappinessCasualObserver - 1; 
    	do wander; 
    }
    
    //RULE: If the Casual Observer is Ingenue, he will start a conversation with the Critic Species, to ask for info, through FIPA
    reflex sendquestiontoCritics {
    	
		if ingenuity{
		do start_conversation to: list(Critic) protocol: 'no-protocol' performative: 'inform' contents: ['I am a Casual Observer, could anyone of the Critical people tell me where I am ?'] ;
		
	
		write '(Time ' + time + '): ' + name + ' sent a private message to Critic Agent.';
		
		do start_conversation to: list(list(Critic)[0], list(Critic)[1]) protocol: 'no-protocol' performative: 'inform' contents: ['Critic person,  you are receiving a msg!'] ;
		write "I am a Casual Observer, could you tell me where I am ?";
		write '-----------------------------------------------------';	
		totalHappinessCasualObserver <- totalHappinessCasualObserver + 1; 
		
		totalInteractions <- totalInteractions + 1; 
	}
   }
   
   
   //BDI Control: if the casual observer has no passion for music, he will go to a Bar, and ask for a Drink
    init {
		if (not passionForMusic) {
			do add_desire(lookingForBar);
        }
    }      	
    // Plan for achieving the 'lookForBar' intention 
	plan doWandering intention: lookingForBar {
		totalHappinessCasualObserver <- totalHappinessCasualObserver - 1; 
		do wander;
	}
	
	rule belief: foundBar new_desire: takeDrinkAtBar strength: 6.0;	
	
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
	    	
	    	
    	
   perceive target: Bar where (each.hasDrink = true and boredness) {
        focus id:myself.foundBarString var:location;
        ask myself {
            do remove_intention(lookingForBar, true);
        }
        
        }
   
 
 
 action askAdrink(Bar nearBar) {
	ask nearBar{
		if self.hasDrink = true{
		write myself.personName + " drank at Bar  "+ self.BarName;
		totalHappinessCasualObserver <- totalHappinessCasualObserver + 1;
	}
	
	}
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


experiment main type: gui
{
	output {
		display map type: opengl {
			species DieHardFan aspect: base;
			species CasualObserver aspect: base;
			species SelfieAddict aspect: base;
			species Critic aspect: base;
			species Bar aspect:default;
			species Concert aspect:default;
			
			chart "Interactions Chart" type: series{
	            data "Total Interactions" value: totalInteractions color: #red;	            
	        }
	        
	        chart "Happiness Metrics" type: series {
	            data "Happiness DieHardFan" value: totalHappinessDieHardFan color: #red;
	            data "Happiness CasualObserver" value: totalHappinessCasualObserver color: #pink; 
	            data "Happiness SelfieAddict" value: totalHappinessSelfieAddict color: #yellow; 
	            data "Happiness Critic" value: totalHappinessCritic color: #blue;
	            data "Happiness SocialButterfly" value: totalHappinessSocialButterfly color: #orange; 
	        }
		}
		
		monitor "Total Interactions" value: totalInteractions;
	}
}