int densityScaleFactor = 1;
double GravitationalConstant = 0.0000000000667;

void setup(){
    
}

void draw(){
  
}

class Body{
  int x, y, radius, gravitationalForce, mass;
  int[] velocity;
  
  Body(int initX, int initY, int initRadius, int[] initVelocity){
    x = initX;
    y = initY;
    radius = initRadius;
    velocity = initVelocity;
    mass = (int)(densityScaleFactor*PI*Math.pow(radius, 2));
  }
  
  void updateBody(int newX, int newY, int newRadius, int[] newVelocity){
    x = newX;
    y = newY;
    radius = newRadius;
    velocity = newVelocity;
    mass = (int)(densityScaleFactor*PI*Math.pow(radius, 2));
  }
  
  void moveBody(int[][] externalBodyData){
    //externalBodyData takes the form:
    //{
    //  {x1, y1, radius1},
    //  {x2, y2, radius2},
    //  {x3, y3, radius3},
    //  ...
    //}
    
    int externalBodyX, externalBodyY, externalBodyRadius, externalBodyMass, netForce;
    int[][] netForceComponents;
    
    for (int i = 0; i < externalBodyData.length; i++){
      externalBodyX = externalBodyData[i][0];
      externalBodyY = externalBodyData[i][1];
      externalBodyRadius = externalBodyData[i][2];
      externalBodyMass = (int)(densityScaleFactor*PI*Math.pow(externalBodyRadius, 2));
      
      //Find the net force's magnitude
      //Find the angle between the force and the x axis
      //Store these values in netForceComponents
      
    }
    
    
    
    for (int i = 0; i < netForceComponents.length; i++){
      //Get the x and y component displacement
    }
    
    //Update the new velocity
    
  }
  
  void drawBody(){
    ellipse(x, y, radius, radius);
  }
}
