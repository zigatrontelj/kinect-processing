//Gravity particles system
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
    // Add a ParticleGravity to the system
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
