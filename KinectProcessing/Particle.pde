//Particle that floats arround
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
