/**
* Name: BasicModel
* Based on the internal empty template. 
* Author: Adele, Kat
* Tags: 
*/

model BasicModel
/* Insert your model definition here */

global {
	int numberOfPeople <- 10;
	int numberOfFoodStores <- 2;
	int numberOfDrinkStores <- 2;
	point infoCenterLocation <- {50,50}; // to make it centralised
	
	init {
		create Person number:numberOfPeople{}
		create FoodStore number:numberOfFoodStores{}
		create DrinkStore number:numberOfDrinkStores{}
		create InfoCenter number: 1
		{
			location <- infoCenterLocation;
		}	
	}
}

species Person skills: [moving] {
	bool isHungry <- false ;//update: flip(0.02);
	bool isThirsty <- false;// update: flip(0.02);
	float prob_ht <- 0.005;
	string personName <- "Undefined";
	int infoCenterSize <- 5;
	point targetPoint <- nil; 
	bool goingInfo <- false;
	bool goingFoodStore <- false;
	bool goingDrinkStore <- false;
	

	action setName(int num) {
		personName <- "Person " + num;
	}
	
	aspect base {	
		rgb agentColor <- rgb("red");
		if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("yellow");
		}		
		draw circle(2) color: agentColor;
	}
	
	
	reflex beIdle when:targetPoint = nil
	{
		do wander; //randomly dancing
	}
	
	reflex stateUpdate
	{
		if(!isHungry){
			if(flip(prob_ht)){
			 	isHungry <- true;
			 }
		}
		if(!isThirsty){
			if(flip(prob_ht)) {
			 	isThirsty <- true;
			 }
		}
	}
	
    reflex decideWhereToGo when: isHungry or isThirsty {
        // If the person is hungry or thirsty and does not have a target, set target to info center
        if (targetPoint = nil) {
            targetPoint <- infoCenterLocation;
            goingInfo <- true;
        }
    }
    
    reflex moveToTarget when: targetPoint != nil
	{	/* default move towards is info center*/
		do goto target: targetPoint.location;
	}

    reflex enterInfo when: goingInfo and (location distance_to(infoCenterLocation) <= infoCenterSize) {
		if(isHungry){
			ask one_of (FoodStore where each.hasFood) {
				myself.targetPoint <- location;
			}
			goingFoodStore <- true;
		} else if(isThirsty){
			ask one_of (DrinkStore where each.hasDrink) {
				myself.targetPoint <- location;
			}
			goingDrinkStore <- true;
		}
		goingInfo <- false;
	}

    reflex enterFoodStore when: goingFoodStore and (location distance_to(targetPoint) <= 1) {
		isHungry <- false;
		goingFoodStore <- false;
		targetPoint <- nil;
		do wander;
	}
	
	reflex enterDrinkStore when: goingDrinkStore and (location distance_to(targetPoint) <= 1) {
		isThirsty <- false;
		goingDrinkStore <- false;
		targetPoint <- nil;
		do wander;
	}
		
}


species InfoCenter {	
	// Get some food and drink store locations
	list<FoodStore> foodStoreLocations <- (FoodStore at_distance 500);
	list<DrinkStore> drinkStoreLocations <- (DrinkStore at_distance 500);
	
	bool hasLocations <- false;
	
	
	reflex listStoreLocations when: hasLocations = false{
		ask foodStoreLocations {
			write "Food store at:" + location; 
		}	
		ask drinkStoreLocations {
			write "Drink store at:" + location; 
		}
		hasLocations <- true;
	}
		
	string infoName <- "Undefined";
	action setName(int num) {
		infoName <- "Info " + num;
	}
	
	aspect default {
		rgb infoColor <- rgb("darkblue");
		draw cube(5) at: location color: infoColor;
	}
}


species FoodStore {
	bool hasFood <- true; //not sure why we need this variable. Do we replenish?
	string storeName <- "Undefined";
	
	action setName(int num) {
		storeName <- "Store " + num;
	}
	
	aspect default
	{
		rgb storeColor <- rgb("lightskyblue"); //0
		if(hasFood){
			storeColor <- rgb("skyblue"); //2
		}
		
		draw triangle(5) at: location color: storeColor;
	}
}

species DrinkStore {
	bool hasDrink <- true;
	string storeName <- "Undefined";
	
	action setName(int num) {
		storeName <- "Store " + num;
	}
	
	aspect default
	{
		rgb storeColor <- rgb("lightgray"); //0
		if(hasDrink){
			storeColor <- rgb("green"); //2
		}
		
		draw triangle(5) at: location color: storeColor;
	}
}

experiment main type: gui
{	
	output {
		display map {
			species Person aspect:base;
			species FoodStore;
			species DrinkStore;
			species InfoCenter;
		}
	}
}

