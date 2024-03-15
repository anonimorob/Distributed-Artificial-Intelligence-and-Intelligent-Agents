/**
* Name: Project3coordination
* Author: Kat and Adele
* Tags: 
*/

model Project3coordination

global {
    int numberOfGuests <- 12;
    int numberOfStages <- 4;
    list<point> stageLocations <- [point(0.0,0.0,0.0), point(0.0,0.0,0.0), point(0.0,0.0,0.0), point(0.0,0.0,0.0)];
    
    
    init {
        create Guest number:numberOfGuests;
              
        loop counter from: 1 to: numberOfGuests {
        	Guest my_agent <- Guest[counter -1];
        	//my_agent <- my_agent.setName(counter);
        }
        
        create Stage number:numberOfStages;
        loop counter from: 1 to: numberOfStages {
        	Stage my_agent <- Stage[counter -1];
        	//my_agent <- my_agent.setName(counter);
        	stageLocations[counter - 1] <- my_agent.location;
            write "Stage location is: " + my_agent.location;
        }
      
    }
}

species Stage skills: [moving, fipa] {
    float lightShow;
    float speakers;
    float band;
    float crowdSize;
    float language;
    float musicType;
    
    int nextAct <- 2;
	int time <- 0 update: time + 1;
	
	reflex newAct when: time = nextAct {
		write "New Act";
		
		lightShow <- rnd(10)/10;
		speakers <- rnd(10)/10;
		band <- rnd(10)/10;
		crowdSize <- rnd(10)/10;
		language <- rnd(10)/10;
		musicType <- rnd(10)/10;
	
		do start_conversation to: list(Guest) protocol: 'fipa-propose' performative: 'inform' contents: ['New Act!'] ;
		
		nextAct <- time + 50;
	}
    
    aspect base {
		draw square(5) color: rgb("blue");
	}

    // Attributes for FIPA communication
    reflex informAgents when: cycle mod 10 = 0 {
    	do start_conversation (to: list(Guest), protocol: 'fipa-propose', performative: 'inform', contents: [lightShow, speakers, band, crowdSize, language, musicType]);
    }
    
    // Reply to requests for attributes
    reflex provideAttributes when: !empty(cfps) {
    	//write " got parameter request";
		loop msg over: cfps {
			if (msg.contents[0] = 'getparameters') {
				// Send parameters
				do cfp (message: msg, contents: [lightShow, speakers, band, crowdSize, language, musicType]);	
			}
		}
    }
    
}

species Guest skills: [moving, fipa] {
	float lightShow <- rnd(0.1, 0.5);
    float speakers<- rnd(0.1, 0.5);
    float band <- rnd(0.1, 0.5);
    float crowdSize <- rnd(0.1, 0.5);
    float language <- rnd(0.1, 0.5);
    float musicType <- rnd(0.1, 0.5);
	
    float highestUtility <- 0.0;
    Stage chosenStage;
    point target <- nil;
    bool waiting <- false;

    aspect base {
		rgb agentColor <- rgb("green");
		
		if (target = nil) {
			do wander;
		} else if (location distance_to(target) <= 10) {
			target <- nil;
		}
				
      	draw circle(1) color: agentColor;
	} 
	
    // Calculate utility for stages and go there
	reflex calculateUtility when: waiting and !empty(cfps) {
    	float utility <- 0.0;
    	
    	loop msg over: cfps {
    		
    		float lightStage <- float(msg.contents[0]);
    		float speakersStage <- float(msg.contents[1]);  
    		float bandStage <- float(msg.contents[2]); 
    		float crowdSizeStage <-float( msg.contents[3]); 
    		float languageStage <- float(msg.contents[4]); 
    		float musicTypeStage <- float(msg.contents[5]);
    		
    		utility <- 0.0;
    		utility <- (lightShow * lightStage) + (speakers * speakersStage) + (band * bandStage)
			+ (crowdSize* crowdSizeStage) + (language * languageStage) + (musicType * musicTypeStage);
			
			if (utility > highestUtility) {
				highestUtility <- utility;
				chosenStage <- msg.sender;
				target <- chosenStage.location;
			}
				
			do end_conversation with:[message:: msg, contents::['Thanks!']];
		}
		
		waiting <- false;
	}
	
	// Request attributes from all stages
	reflex requestStageAttributes when: !waiting and !empty(informs) {
		
		write "asking for stage parameters";
		loop informMsg over: informs {
			string receivedContent <- informMsg.contents;
			do end_conversation message: informMsg contents: ['Thanks!'];
		}
		
		waiting <- true;
		
		// Ask for act parameters
		do start_conversation to: list(Stage) protocol: 'no-protocol' performative: 'cfp' contents: ['getparameters'] ;		
	}
	
	reflex moveToTarget when: target != nil {
		write "going to target";
		do goto target: target;
	}
      
}

experiment MyExperiment type: gui {
    output {
        display myDisplay {
            species Stage aspect:base;
            species Guest aspect:base;
        }
    }
}
