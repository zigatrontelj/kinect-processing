import KinectPV2.KJoint; //<>//
import KinectPV2.*;

//*************************
boolean testMode = false;
static final int screenwidth = 1920;
static final int screenheight = 1080;
//*************************

KinectPV2 kinect;

ParticleGravitySystem ps1;
ParticleGravitySystem ps2;
ParticleGravitySystem ps3;

ParticleSystem ps;

boolean clap = false;
int clapcount = 0;
int colorpoint = 0;
int[][] colors = new int[][]{
  { 255, 255, 255 },
  { 0, 255, 246 },
  { 0, 255, 114 },
  { 255, 0, 123 },
  { 242, 255, 0 },
  { 182, 0, 255 }
};

void setup() {
  size(1920, 1080, P3D);
  
  kinect = new KinectPV2(this);
  
  kinect.enableDepthImg(true);
  kinect.enableSkeletonColorMap(true);
  
  kinect.init();
  
  ps1 = new ParticleGravitySystem(1, new PVector(0, 0), new PVector(0, 0.05));
  ps2 = new ParticleGravitySystem(1, new PVector(0, 0), new PVector(0, 0.05));
  ps3 = new ParticleGravitySystem(1, new PVector(0, 0), new PVector(0, 0.05));
  
  ps = new ParticleSystem(new PVector(width/2, 50));
  for (int i=0; i<2000; i++)
  {
    ps.addParticle();
  }
  
}


void draw() {
  background(0);
  
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  
  //Omeji delovanje na 2 skeletona
  if(skeletonArray.size() > 2){
    skeletonArray.subList(2, skeletonArray.size()).clear();
  }
  
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    
    
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      KJoint rightjoint = joints[KinectPV2.JointType_HandRight];
      KJoint leftjoint = joints[KinectPV2.JointType_HandLeft];
      
      KJoint head = joints[KinectPV2.JointType_SpineShoulder];
      
      //Right hand tracked
      if(rightjoint.getState() != KinectPV2.HandState_NotTracked){
        
        ps.move_away_from(rightjoint.getX(), rightjoint.getY(), 120);
        
        ps1.origin = new PVector(rightjoint.getX(), rightjoint.getY());        
        
        float accel;
        
        //Right hand above head
        if(rightjoint.getY() >= head.getY()){
          accel = random(-0.05, 0.8);
        } else {
          accel = random(-2, 0);
        }
        ps1.addParticleGravity(new ParticleGravity(new PVector(rightjoint.getX(), rightjoint.getY()), new PVector(0, accel)));
      }
      
      //Left hand tracked
      if(leftjoint.getState() != KinectPV2.HandState_NotTracked){
        
        ps.move_away_from(leftjoint.getX(), leftjoint.getY(), 120);
        
        ps2.origin = new PVector(leftjoint.getX(), leftjoint.getY());
        
        float accel;
        
        //Left hand above head
        if(leftjoint.getY() >= head.getY()){
          accel = random(-0.05, 0.8);
        } else {
          accel = random(-2, 0);
        }
        
        ps2.addParticleGravity(new ParticleGravity(new PVector(leftjoint.getX(), leftjoint.getY()), new PVector(0, accel)));
      }
      
      //Plosk
      if(PointsTouching(leftjoint, rightjoint) && clapcount > 30){
         clap = true;
         
         ps.move_away_from(leftjoint.getX(), leftjoint.getY(), 350);
         
         ps3.addParticleGravity(new ParticleGravity(new PVector(rightjoint.getX(), rightjoint.getY()), new PVector(0, random(-0.02, 0.8))));
        
         clapcount = 0;
      } else {
          clapcount++;
      }
      
      if(skeletonArray.size() > 1){
        
        KSkeleton skeleton1 = (KSkeleton) skeletonArray.get(0);
        KSkeleton skeleton2 = (KSkeleton) skeletonArray.get(1);
        
        KJoint[] joints1 = skeleton1.getJoints();
        KJoint[] joints2 = skeleton2.getJoints();
        
        KJoint spine1 = joints1[KinectPV2.JointType_SpineMid];
        
        KJoint spine2 = joints2[KinectPV2.JointType_SpineMid];
        
        //Ce sta dovolj blizu
        if(PointsClose(spine1, spine2)){
           ps.move_away_from((spine1.getX()+spine2.getX())/2, (spine1.getY()+spine2.getY())/2, 500);
        }
        
        
        
      }
      
      ps1.run();
      ps2.run();
      ps3.run();
      
      
      if(testMode == true){
        drawBody(joints);
        drawHandState(joints[KinectPV2.JointType_HandRight]);
        drawHandState(joints[KinectPV2.JointType_HandLeft]);
      }
      
    }
    
  }
  

  // Translate 
  pushMatrix();
  translate(width/2, height/2, -2250);

  // We're just going to calculate and draw every x pixel
  int skip = 4;

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepthData();


  if(clap == true){
    stroke(colors[colorpoint%6][0], colors[colorpoint%6][1], colors[colorpoint%6][2]);
    colorpoint++;
  } else {
    stroke(colors[colorpoint%6][0], colors[colorpoint%6][1], colors[colorpoint%6][2]);
  }
  
  strokeWeight(3);
  beginShape(POINTS);
  for (int x = 0; x < 512; x+=skip) {
    for (int y = 0; y < 424; y+=skip) {
      int offset = x + y * 512;
      int d = depth[offset];
      
      //Izračunaj x,y,z na podlagi informacije o globini
      //calculte the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, d);

      // Draw a point
      vertex(point.x, point.y, point.z);
    }
  }
  endShape();

  popMatrix();

  fill(255);
  
  clap = false;
  
  ps.run();

}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

boolean PointsTouching(KJoint leftjoint, KJoint rightjoint){
  //Check if hands are touching 
  if ((Math.abs(leftjoint.getX() - rightjoint.getX()) < 50) && (Math.abs(leftjoint.getY() - rightjoint.getY()) < 50)) {
    return true;
  } else {
    return false;
  }
}

boolean PointsClose(KJoint leftjoint, KJoint rightjoint){
  //Check if points are near
  if ((Math.abs(leftjoint.getX() - rightjoint.getX()) < 300) && (Math.abs(leftjoint.getY() - rightjoint.getY()) < 300)) {
    return true;
  } else {
    return false;
  }
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}

class ParticleGravitySystem {

  ArrayList<ParticleGravity> particles;    // An arraylist for all the particles
  PVector origin;   // An origin point for where particles are birthed
  PVector acceleration;

  ParticleGravitySystem(int num, PVector v, PVector a) {
    particles = new ArrayList<ParticleGravity>();   // Initialize the arraylist
    origin = v.copy();                        // Store the origin point
    a = a.copy();
    for (int i = 0; i < num; i++) {
      particles.add(new ParticleGravity(origin, a));    // Add "num" amount of particles to the arraylist
    }
  }


  void run() {
    // Cycle through the ArrayList backwards, because we are deleting while iterating
    for (int i = particles.size()-1; i >= 0; i--) {
      ParticleGravity p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void addParticleGravity() {
    ParticleGravity p;
    // Add either a ParticleGravity or CrazyParticleGravity to the system
    p = new ParticleGravity(origin, new PVector(0, 0.08));
    particles.add(p);
  }

  void addParticleGravity(ParticleGravity p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    return particles.isEmpty();
  }
}


// A simple ParticleGravity class

class ParticleGravity {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  ParticleGravity(PVector l, PVector a) {
    acceleration = a;
    velocity = new PVector(random(-2, 1), random(-3, 0));
    position = l.copy();
    lifespan = 255.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    ellipse(position.x, position.y, 1, 1);
  }

  // Is the particle still useful?
  boolean isDead() {
    return (lifespan < 0.0);
  }
}



//Floating particles

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
 
  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }
 
  void addParticle() {
    particles.add(new Particle(origin));
  }
 
  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
//      if (p.isDead()) {
        //    particles.remove(i);
//      }
    }
  }
  void move_away_from( float x, float y, int radious){
    for(Particle p : particles){
      float d = dist(x,y,p.position.x, p.position.y);
      if( d < radious ){ // Only move points near click.
        p.velocity.x += map(d,0,radious,0.5,0.1)*(p.position.x - x);
        p.velocity.y += map(d,0,radious,0.5,0.1)*(p.position.y - y);
      }
    }
  }
 
}
 
 
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
 
  PVector home;
 
  Particle(PVector l) {
    acceleration = new PVector(0, 0);
    velocity = new PVector(0,0);//random(-0.0001, 0.00001), random(-0.001, 0.0001));
 
    l=new PVector(random(0, screenwidth), random(0, screenheight));
    position = l.copy();
    home = position.copy();
    lifespan = 255.0;
  }
 
  void run() {
    update();
    display();
  }
 
  // Method to update position
  void update() {
    acceleration.x = -0.01*(position.x - home.x);
    acceleration.y = -0.01*(position.y - home.y);
    velocity.add(acceleration);
    velocity.mult(0.9);
    position.add(velocity);
    //   lifespan -= 1.0;
  }
 
  // Method to display
  void display() {
    noStroke();//stroke(255, lifespan);
    //fill(255, lifespan);
    float notblue = map(abs(velocity.mag()),0,5,255,0); 
    fill(notblue,notblue,255);
    ellipse(position.x, position.y, 4, 4);
  }
 
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
