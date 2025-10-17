int densityScaleFactor = 1;
double GravitationalConstant = 66.7;
double timeIncrement = 1;
double drawSpeed = 1/3; //Max 1
int frame = 0;

Body[] bodiesArray = new Body[3];
double[][] updatedBodiesComponents = new double[bodiesArray.length][4];

void setup(){
  background(0, 0, 0);
  //noLoop();
  size(800, 600);
  
  bodiesArray[0] = new Body(100, 100, 2, (7*PI)/4, 10);
  bodiesArray[1] = new Body(200, 200, 2, (3*PI)/4, 10);
  bodiesArray[2] = new Body(200, 150, 0, 0, 10);
}

void draw(){
  frame += 1;
  if ((int)(frame%(1/drawSpeed)) == 0){
  background(0, 0, 0);
  
  for (int i = 0; i < bodiesArray.length; i++){
      updatedBodiesComponents[i] = bodiesArray[i].moveBody(bodiesArray);
    }
    
    double netX, netY, netVelocity, netAngle;
    for (int i = 0; i < bodiesArray.length; i++){
      netX = updatedBodiesComponents[i][0];
      netY = updatedBodiesComponents[i][1];
      netVelocity = updatedBodiesComponents[i][2];
      netAngle = updatedBodiesComponents[i][3];
      
      bodiesArray[i].updateBody(netX, netY, netVelocity, netAngle);
    }
  }
  
  frame %= 60;
}

class Body{
  int radius;
  double x, y, mass, velocity, velocityX, velocityY, angle;
  
  Body(double initX, double initY, double initVelocity, double initAngle, int initRadius){
  
    x = Math.min(Math.max(initX, 0), width);
    y = Math.min(Math.max(initY, 0), height);
    radius = initRadius;
    velocity = initVelocity;
    angle = initAngle%(2*PI);
    velocityX = velocity*Math.cos(angle);
    velocityY = velocity*Math.sin(angle);
    mass = densityScaleFactor*PI*Math.pow(radius, 2);
    
    this.drawBody();
  }
  
  void updateBody(double newX, double newY, double newVelocity, double newAngle){
    
    x = Math.min(Math.max(newX, 0), width);
    y = Math.min(Math.max(newY, 0), height);
    velocity = newVelocity;
    angle = newAngle%(2*PI);
    mass = densityScaleFactor*PI*Math.pow(radius, 2);
    
    this.drawBody();
  }
  
  double[] moveBody(Body[] bodiesArray){
    
    //A body at a certain index's components
    double externalX, externalY, externalMass;
    
    //Components from the interaction between this current body and the external ones
    double differenceX, differenceY, distance, acceleration, accelerationX, accelerationY, accelerationAngle;
    
    //Final values
    double netX = this.x;
    double netY = this.y;
    double netVelocityX = this.velocityX;
    double netVelocityY = this.velocityY;
    double netVelocity, netAngle;
    
    for (int i = 0; i < bodiesArray.length; i++){
      if (bodiesArray[i] != this){
        
        //Unpack bodyArray
        externalX = bodiesArray[i].x;
        externalY = bodiesArray[i].y;
        externalMass = bodiesArray[i].mass;
        
        //Get the distance between the two bodies and the difference in their positions
        distance = getDistance(externalX, externalY, this.x, this.y);
        differenceX = externalX - this.x;
        differenceY = externalY - this.y;
        
        //Calculate how fast the current body will accelerate towards the external body
        acceleration = GravitationalConstant*(externalMass/(distance*distance));
        accelerationAngle = getAngle(differenceX, differenceY);
        accelerationX = acceleration*Math.cos(accelerationAngle);
        accelerationY = acceleration*Math.sin(accelerationAngle);
        
        //Calculate the net velocity and movement
        netVelocityX += getVelocity(this.velocityX, accelerationX, timeIncrement);
        netVelocityY += getVelocity(this.velocityY, accelerationY, timeIncrement);
        netX += getDistanceChange(this.velocityX, accelerationX, timeIncrement);
        netY += getDistanceChange(this.velocityY, accelerationY, timeIncrement);
      }
    }

    netVelocity = Math.sqrt(Math.pow(netVelocityX, 2) + Math.pow(netVelocityY, 2));
    netAngle = getAngle(netVelocityX, netVelocityY);
    
    //The last element will be used for the index of where this body is in the global bodiesArray
    double[] updatedComponents = {netX, netY, netVelocity, netAngle};
    
    return updatedComponents;
  }
  
  void drawBody(){
    fill(255, 0, 0);
    ellipse((float)this.x, (float)this.y, this.radius, this.radius);
  }
}

double getAngle(double xLength, double yLength){
  if (xLength == 0 && yLength == 0){
    throw new java.lang.RuntimeException("getAngle received an illegal value (received the indeterminant form 0/0 from both parameters being 0)");
    
  } else if(xLength > 0 && yLength == 0){
    return 0;
    
  } else if(xLength < 0 && yLength == 0){
    return PI;
    
  } else if(xLength == 0 && yLength > 0){
    return PI/2;
    
  } else if(xLength == 0 && yLength < 0){
    return (3*PI)/2;
    
  } else if(xLength > 0 && yLength > 0){ //First quadrant (+x, +y)
    return Math.atan(yLength/xLength);
    
  } else if(xLength < 0 && yLength > 0){ //Second quadrant (-x, +y)
    return PI + Math.atan(yLength/xLength);
    
  } else if(xLength < 0 && yLength < 0){ //Third quadrant (-x, -y)
    return PI + Math.atan(yLength/xLength);
    
  } else if(xLength > 0 && yLength < 0){ //Fourth quadrant (+x, -y)
    return 2*PI + Math.atan(yLength/xLength);
    
  } else {
    throw new java.lang.RuntimeException("getAngle received an illegal value (received values it could not handle)");
  }
}

double getDistance(double x1, double y1, double x2, double y2){
  return Math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
}

double getVelocity(double initialVelocity, double acceleration, double time){
  return initialVelocity + acceleration*time;
}

double getDistanceChange(double initialVelocity, double acceleration, double time){
  return initialVelocity*time + (acceleration*time*time)/2;
}
