var previousProcessingInstanceData = undefined;

var timeoutWait = 50; //Milliseconds

var failedToFindNewProcessingSketchCount;
var maxFailedToFindNewProcessingSketchCount = 10;

var keydownFlag = false;

//Poll until the processing sketch has fully loaded. Prevents JavaScript from accessing instances of the processing sketch before the new sketch has fully loaded
function pollForProcessingSketch(event = null, calledFromTimeout = false){ //event variable isnt used, it fills a spot for the keydown event listner so the calledFromTimeout isnt interfered with
	let currentProcessingInstance = Processing.getInstanceById("chemotaxisCanvas");
	console.log("Polling..."); //For debugging
	
	//For when this function is not called from the setTimeout methods inside this function (aka the first call of the function)
	if (!calledFromTimeout){
		console.clear();
		failedToFindNewProcessingSketchCount = 0;
	}
  
	//Prevent too many function calls from constant repeated fails
	if (failedToFindNewProcessingSketchCount >= maxFailedToFindNewProcessingSketchCount){
		console.log(">Failed to load a new canvas instance\nCeasing function calls...\n ");
		return;
	} else if (!currentProcessingInstance){ //Verify the instance exists
		console.log(">Failed to load a new canvas instance\nRetrying...\n ");
    
    //Poll until the processing sketch exists, passing true to prevent the console being cleared from a setTimeout call
		setTimeout(pollForProcessingSketch, timeoutWait, null, true);
	  return;
	}
	
	let currentProcessingInstanceData = currentProcessingInstance.REPLACETHIS();
	let processingInstanceEquality = previousProcessingInstanceData == currentProcessingInstanceData;
	
	//For debugging
	console.log(" - Previous canvas data: " + previousProcessingInstanceData);
	console.log(" - Current canvas data: " + currentProcessingInstanceData);
	console.log(" - Canvas data equality (should be false): " + processingInstanceEquality);
	
	//Verify the instances aren't the same instance
	if (processingInstanceEquality){
		console.log(">Failed to load a new canvas instance\nRetrying...\n ");
		failedToFindNewProcessingSketchCount++;

    //Poll until a new processing sketch loads, passing true to prevent the console being cleared from a setTimeout call
		setTimeout(pollForProcessingSketch, timeoutWait, null, true);
		return;
	}
	
	updateBodyCount(currentProcessingInstance);
	
	//Disallows the now loaded sketch to be loaded again next function call
	previousProcessingInstanceData = currentProcessingInstanceData;
}

//Updates the span that displays the sum of all dice on the canvas
function updateBodyCount(processingInstance){
	let bodyCountFooter = document.getElementById("bodyCountFooter");
	let bodyCount = processingInstance.REPLACETHIS();
	
	//For debugging
	console.log("Body count updating...");
	console.log(" - Body count: " + bodyCount);
	
	//Update the dice sum span
	bodyCountFooter.innerText = bodyCount;
}

//Verify only either the up or down arrow were pressed
function verifyValidKeyPress(event){
  //Allow only 1 update per keydown event
	if ((event.key === "ArrowUp" || event.key === "ArrowDown") && !keydownFlag){
		pollForProcessingSketch();
		keydownFlag = true;
	}
}

//Resets the keydownFlag when the key is released so that the pollForProcessingSketch function can be called again by the verifyValidKeyPress function on the next keydown event
function resetKeydown(){
	keydownFlag = false;
}

//Poll for processing sketch once all the HTML has loaded
window.onload = pollForProcessingSketch;

//Update the sum and total amount of dice when the canvas is clicked/when the a key is pressed
var canvasReference = document.getElementById("chemotaxisCanvas");
canvasReference.addEventListener("keydown", verifyValidKeyPress);
canvasReference.addEventListener("keyup", resetKeydown);

