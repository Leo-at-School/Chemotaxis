//Physics variables
int densityScaleFactor = 1;
double gravitationalConstant = 66.7;
double timeIncrement = 0.01;
double dragCoefficient = 1.17;
double airDensity = 0.1;

//Program's variables
boolean keydownFlag = false; //Flag to allow only 1 exxecution per key press
double drawSpeed = 1; //Max 1
int bodyAmount = 7;
int frame = 0;

Body[] bodiesArray = new Body[bodyAmount];
double[][] updatedBodiesComponents = new double[bodiesArray.length][4];

void setup(){
  background(0, 0, 0);
  size(800, 600);
  
  double randomX, randomY, randomVelocity, randomAngle;
  int randomRadius;
  for (int i = 0; i < bodiesArray.length; i++){
    randomX = (Math.random()*3*width)/4 + width/8;
    randomY = (Math.random()*3*height)/4 + height/8;
    randomVelocity = Math.random()*5;
    randomAngle = Math.random()*2*PI;
    randomRadius = (int)(Math.random()*20 + 10);
    
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
  double maxVelocityX = 250;
  double maxVelocityY = 250;
  
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
    //Air resistance components
    double netAirResistanceX, netAirResistanceY;
    netAirResistanceX = getAirResistance(airDensity, this.velocityX, dragCoefficient, 2*this.radius);
    netAirResistanceY = getAirResistance(airDensity, this.velocityY, dragCoefficient, 2*this.radius);
    
    //The external bodies' components
    double externalX, externalY, externalMass;
    
    //Components from the interaction between this current body and the external ones
    double distance, force, forceAngle, netAccelerationX, netAccelerationY, netVelocityX, netVelocityY;
    
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
        force = (gravitationalConstant*externalMass*this.mass)/(distance*distance);
        forceAngle = getAngle(externalX - this.x, externalY - this.y);
        netForceX += force*Math.cos(forceAngle);
        netForceY += force*Math.sin(forceAngle);
      }
    }
    
    netForceX += -Math.signum(netForceX)*netAirResistanceX;
    netForceY += -Math.signum(netForceY)*netAirResistanceY;
    
    netAccelerationX = netForceX/this.mass;
    netAccelerationY = netForceY/this.mass;
    
    netVelocityX = getFinalVelocity(this.velocityX, netAccelerationX, timeIncrement);
    netVelocityY = getFinalVelocity(this.velocityY, netAccelerationY, timeIncrement);
    
    if (Math.signum(netVelocityX) == 1){
      netVelocityX = Math.min(netVelocityX, maxVelocityX);
    } else if (Math.signum(netVelocityX) == -1){
      netVelocityX = Math.max(netVelocityX, -maxVelocityX);
    }
    
    if (Math.signum(netVelocityY) == 1){
      netVelocityY = Math.min(netVelocityY, maxVelocityY);
    } else if (Math.signum(netVelocityY) == -1){
      netVelocityY = Math.max(netVelocityY, -maxVelocityY);
    }
    
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
    System.out.println(xLength);
    System.out.println(yLength);
    throw new java.lang.RuntimeException("getAngle received an illegal value (received values it could not handle)");
  }
}

//Distance between two points (x1, y1) and (x2, y2)
double getDistance(double x1, double y1, double x2, double y2){
  return Math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
}

//The final velocity using the equation: v = v0 + a*t
double getFinalVelocity(double initialVelocity, double acceleration, double time){
  return initialVelocity + acceleration*time;
}

//Displacement using the equation: delta x = v0*t + 1/2(a*t^2)
double getDistanceChange(double initialVelocity, double acceleration, double time){
  return initialVelocity*time + (acceleration*time*time)/2;
}

//The force of air resistance in a particular axis using the drag equation: F = 1/2(p*v^2*c*A)
double getAirResistance(double airDensity, double airVelocity, double dragCoefficient, double referenceArea){
 return (airDensity*airVelocity*airVelocity*dragCoefficient*referenceArea)/2;
}
