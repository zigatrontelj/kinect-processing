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
