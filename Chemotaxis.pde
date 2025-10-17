int densityScaleFactor = 1;
double GravitationalConstant = 66.7;
double timeIncrement = 0.1;
double drawSpeed = 1; //Max 1
double dragCoefficient = 0.5;
int frame = 0;

Body[] bodiesArray = new Body[10];
double[][] updatedBodiesComponents = new double[bodiesArray.length][4];

void setup(){
  background(0, 0, 0);
  size(800, 600);
  
  double randomX, randomY, randomVelocity, randomAngle;
  int randomRadius;
  for (int i = 0; i < bodiesArray.length; i++){
    randomX = (Math.random()*3*width)/4 + width/8;
    randomY = (Math.random()*3*height)/4 + height/8;
    randomVelocity = Math.random()*10;
    randomAngle = Math.random()*2*PI;
    randomRadius = (int)(Math.random()*10 + 10);
    
    bodiesArray[i] = new Body(randomX, randomY, randomVelocity, randomAngle, randomRadius);
  }
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

void mouseClicked(){
  setup();
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
    
    if (x == 0 || x == width){
      angle = PI - angle;
    } else if(y == 0 || y == height){
      angle = 2*PI - angle;
    }
    
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
    
    if (x == 0 || x == width){
      angle = PI - angle;
    } else if(y == 0 || y == height){
      angle = 2*PI - angle;
    }
    
    velocityX = velocity*Math.cos(angle);
    velocityY = velocity*Math.sin(angle);
    mass = densityScaleFactor*PI*Math.pow(radius, 2);
    
    this.drawBody();
  }
  
  double[] moveBody(Body[] bodiesArray){
    
    //A body at a certain index's components
    double externalX, externalY, externalMass;
    
    //Components from the interaction between this current body and the external ones
    double distance, force, forceAngle, netForce, netForceAngle, netAccelerationX, netAccelerationY, netVelocityX, netVelocityY;
    
    //Final values
    double netX = this.x;
    double netY = this.y;
    double netForceX = 0;
    double netForceY = 0;
    double netVelocity, netAngle;
    
    for (int i = 0; i < bodiesArray.length; i++){
      if (bodiesArray[i] != this){
        
        //Unpack bodyArray
        externalX = bodiesArray[i].x;
        externalY = bodiesArray[i].y;
        externalMass = bodiesArray[i].mass;
        
        //Get the distance between the two bodies and the difference in their positions
        distance = getDistance(externalX, externalY, this.x, this.y);
        
        //Calculate the net forces for the x and y components
        force = (GravitationalConstant*externalMass*this.mass)/(distance*distance);
        forceAngle = getAngle(externalX - this.x, externalY - this.y);
        netForceX = force*Math.cos(forceAngle);
        netForceY = force*Math.sin(forceAngle);
      }
    }
    netForceAngle = getAngle(netForceX, netForceY);
    netForceX -= airResistance*Math.cos(netForceAngle);
    netForceY -= airResistance*Math.sin(netForceAngle);
    
    netAccelerationX = netForceX/this.mass;
    netAccelerationY = netForceY/this.mass;
    
    netVelocityX = getFinalVelocity(this.velocityX, netAccelerationX, timeIncrement);
    netVelocityY = getFinalVelocity(this.velocityY, netAccelerationY, timeIncrement);
    
    netX += getDistanceChange(this.velocityX, netAccelerationX, timeIncrement);
    netY += getDistanceChange(this.velocityY, netAccelerationY, timeIncrement);

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

double getFinalVelocity(double initialVelocity, double acceleration, double time){
  return initialVelocity + acceleration*time;
}

double getDistanceChange(double initialVelocity, double acceleration, double time){
  return initialVelocity*time + (acceleration*time*time)/2;
}

double getAirResistance(dragCoefficient, airDensity, area, velocity, frontalArea){
 return;
}
