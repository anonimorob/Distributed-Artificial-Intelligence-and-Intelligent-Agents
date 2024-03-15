/**
* Name: Homework1
* Guest Party
* Author: Adele and Kat
*/


model FestivalProject

global {
	int numberOfPeople <- 40;
	int numberOfStores <- 6;
	int numberOfInfo <- 3;         
	int distanceThreshold <- 2;
	point infoCenterPoint<- nil;    //Each person knows the location of the InfoPoint 
	list<point> infoCenterPoints <- [point(0.0,0.0, 0.0), point(0.0,0.0, 0.0),point(0.0,0.0, 0.0)];  //works for 3 infopoints

	//NEW PART
	int n_queens <- 11;
	int closeCells <- 8;
	bool isComputing <- false;
	
	// initializing agents
	init {
		/**
		create Person number:numberOfPeople;
		create Store number:numberOfStores;
		create InfoCenter number:numberOfInfo;
		* 
		*/
		create Queen number: n_queens;
		
		/**
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
        * 
        */
	}
	
	
	list<Queen> Queens;
	list<Square> Squares;
}

// defining skills  and aspect of specie Person
species Person skills: [moving] {
	bool isHungry <- false ;//update: flip(0.02);
	bool isThirsty <- false;// update: flip(0.02);
	float prob_ht <- 0.005;
	string personName <- "Undefined";
	point targetPoint <- nil; 
	bool goingInfo <- false;
	bool goingStore <- false;
	
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

// enjoy the party until hungry or thirsty
	reflex beIdle when:targetPoint = nil
	{
		
		if (isHungry or isThirsty){
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
		if !(isHungry or isThirsty){
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
					write myself.personName + ": Can you suggest me where to eat / drink " + self.infoName;
        			myself.targetPoint <- point(self.checkStore(myself.isHungry,myself.isThirsty,myself.personName));
        			write " targetPoint is :" + myself.targetPoint;
        }
        
		goingInfo <- false;
		goingStore <- true; 
		
	}
	
	reflex enterStore when: targetPoint != nil and goingStore = true and location distance_to(targetPoint) < distanceThreshold
	{
		if (isThirsty) {
			ask Store {
				if self.hasDrink =true{
					write myself.personName + " drank at store "+ self.storeName;
					myself.isThirsty <- false;
					}	
				}
			} 
		if (isHungry) {
			ask Store  {
				if self.hasFood =true{
					write myself.personName + " ate at store "+ self.storeName;
					myself.isHungry <- false;
					}	
				}
			}
		goingStore <- false;
		targetPoint <- nil; 
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
	
	action checkStore(bool hungry, bool thirsty, string personName) {
			bool found <-false;
			list<point> storesTarget;
			
			
			loop counter from: 1 to: numberOfStores {
				Store my_agent <- Store[counter - 1];
					ask Store{
						if(hungry){
							if  (self.hasFood=true){
								write personName +" can eat at store " + point(self.location) ;
								storesTarget <+ self.location ;								
								}
							}
						else if(thirsty){
							if  (self.hasDrink=true){
								write personName +" can drink at store " + point(self.location) ;
								storesTarget <+ self.location ;	
								}
							}	
	        		}
        		}
        		if !(empty(storesTarget))
	        		{	
	        			return storesTarget closest_to self.location;
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


// NEW PART QUEEN

species Queen{
	Square mySquare <- one_of (Square);
	list<list<int>> occupancyGrid; //2 dimensions
	
	//populate free cells with available n_queens 
	init{
		loop square over: mySquare.closeCells{
			if square.queen = nil{
				mySquare <- square; 
				break;
			}
		}
		location <- mySquare.location;
		mySquare.queen <- self;
		
		add mySquare.queen to: Queens;
		
		do setAgainSquare; 
		
	}
	//set all the occupancy grids of each queen to 0
	action setAgainSquare{
        self.occupancyGrid <- [];
        loop m from:0 to: n_queens-1{
            list<int> mList;
            loop n from:0 to: n_queens-1{
                add 0 to: mList;    
            }
            add mList to: occupancyGrid;
        }
}

action calculateOccupancyGrid{
        do setAgainSquare;
        
        // Identify occupied squares
        loop square over: Squares{
            if square.queen != nil and square.queen != self{
                self.occupancyGrid[square.grid_x][square.grid_y] <- 1000;
            }
        }
        
        // Identify free squares
            loop square over: Squares{
                int m <- square.grid_x;  //row
                int n <- square.grid_y;  //column
                if self.occupancyGrid[int(m)][int(n)] = 1000{ //occupied
                    loop i from: 1 to:n_queens{
                        
                        // Up
                        int mi <- int(m) + i;
                        if mi < n_queens{
                            self.occupancyGrid[mi][n] <- self.occupancyGrid[mi][n] + 1;
                        }
                        
                        //Down
                        int n_mi <- int(m) - i;
                        if n_mi > -1{
                            self.occupancyGrid[n_mi][n] <- self.occupancyGrid[n_mi][n] + 1;
                        }
                        
                        // Right
                        int ni <- int(n) + i;
                        if ni < n_queens{
                            self.occupancyGrid[m][ni] <- self.occupancyGrid[m][ni] + 1;
                        }
                        
                        //Left
                        int n_ni <- int(n) - i;
                        if n_ni > -1{
                            self.occupancyGrid[m][n_ni] <- self.occupancyGrid[m][n_ni] + 1;
                        }
                        
                        //top right diagonal
                        if mi < n_queens and ni < n_queens{
                            self.occupancyGrid[mi][ni] <- self.occupancyGrid[mi][ni] + 1;
                        }
                        
                        //bottom right diagonal
                        if n_mi > -1 and ni < n_queens{
                            self.occupancyGrid[n_mi][ni] <- self.occupancyGrid[n_mi][ni] + 1;
                        }
                        
                        //top left diagonal
                        if mi < n_queens and n_ni > -1{
                            self.occupancyGrid[mi][n_ni] <- self.occupancyGrid[mi][n_ni] + 1;
                        }
                        
                        //bottom left diagonal
                        if n_mi > -1 and n_ni > -1{
                            self.occupancyGrid[n_mi][n_ni] <- self.occupancyGrid[n_mi][n_ni] + 1;
                        }
                    }
                }
            }
    }
    //f that returns a list of points occupied/available respect to the value 0/1000 passed
    list<point> availableSquares(int val) {
        list<point> Checks;
        loop square over: Squares{
            int m <- square.grid_x;
            int n <- square.grid_y;
            if self.occupancyGrid[int(m)][int(n)] = val and !(m = mySquare.grid_x and n = mySquare.grid_y){
            	add {int(m),int(n)} to: Checks;
            }
        }
        return Checks;
    }
    
   //f that return a random queen from a list filled with queens on same raw/column/diagonal
    Queen findQueenInSightbyLocation(int x){
    	list<Queen> n_queensInSight;
    	
    	loop square over: Squares{
            int m <- square.grid_x;
            int n <- square.grid_y;
            
            if self.occupancyGrid[m][n] > 999{   //row
            	if m = self.mySquare.grid_x {
            		add square.queen to: n_queensInSight;
            	}
            	else if n = self.mySquare.grid_y {   //column
            		add square.queen to: n_queensInSight;
            	}
            	else{                               //diagonal
            		int diff_x <- abs(m - self.mySquare.grid_x);
            		int diff_y <- abs(n - self.mySquare.grid_y);
            		if diff_x = diff_y{
            			add square.queen to: n_queensInSight;
            		}
            	}
            }
        }
    	
    	if length(n_queensInSight) > 0{
    		Queen sight <- n_queensInSight[rnd(0, length(n_queensInSight)-1)];
    		return sight;	
    	} else{
    		return nil;
    	}
    }
    // to move the queen in one of the available points
    action needToMove{
    	do calculateOccupancyGrid();
	    if self.occupancyGrid[mySquare.grid_x][mySquare.grid_y] != 0{
	    	list<point> possibleChecks <- availableSquares(0);
	    	if length(possibleChecks) > 0 {
	    		point possiblePoint <- possibleChecks[rnd(0,length(possibleChecks)-1)];
	    		loop c over: Squares {
	    			if c.grid_x = possiblePoint.x and c.grid_y = possiblePoint.y and c.queen = nil{
	    				mySquare.queen <- nil;
	    				mySquare <- c;
	    				location <- c.location;
	    				mySquare.queen <- self;
	    				
	    				write name;
	    				write "Free Points: " + possibleChecks;
	    				write "New Position: " + c.grid_x + ", " + c.grid_y;
	    				
	    				break;
	    			}
	    		}
	    	}
	    	else{
	    		write "The queen cannot move from the position: " + self.mySquare.grid_x + ", " + self.mySquare.grid_y;
	    		// Communicate with the other queens
	    		Queen sight <- findQueenInSightbyLocation(0);
	    		if sight != nil{
	    			Square sightCell;
	    			ask sight{
	    				write "Currently I am at the position : " + myself.mySquare.grid_x + ", " + myself.mySquare.grid_y + " But I am trying to move to the position: " + self.mySquare.grid_x + ", " + self.mySquare.grid_y;
	    				sightCell <- self.mySquare;
	    			}
	    			Square target;
	    			float min_distance <- 1000.0;
	    			//find between the close cells to the sight cell, the one with shorter distance from me
	    			loop s over:sightCell.closeCells{
	    				float dist <- mySquare.location distance_to s.location;
	    				if dist < min_distance and dist!=0 and s.queen = nil{
	    					min_distance <- dist;
	    					target <- s;
	    				}
	    			}
	    			write "The new location is: " + target.grid_x + ", " + target.grid_y;
	    			mySquare.queen <- nil;
	    			mySquare <- target;
	    			location <- target.location;
	    			mySquare.queen <- self;
	    		}
	    	}
	    }
	}
    
    reflex amIsafe when: !isComputing{
    	isComputing <- true;
    	do needToMove;
    	isComputing <- false;
    }
    
    
    aspect base {
        draw circle(1.5) color: #black ;
    }
}

grid Square width: n_queens height: n_queens neighbors: closeCells {
    list<Square> closeCells  <- (self neighbors_at 2);
    Queen queen <- nil;
    
    init{
        add self to: Squares;
       	if(even(grid_x) and even(grid_y)){
			color <- #pink;
		}
		else if (!even(grid_x) and !even(grid_y)){
			color <- #pink;
		}
		else {
			color <- #white;
		}
    }
}

experiment myExperiment type:gui {
	output {
		display myDisplay {
			//species Person aspect:base;
			//species Store aspect:base;
			//species InfoCenter aspect:base;
			grid Square border: #black;
			species Queen aspect: base;
		}
	}
}
