import React from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import './Hero.css';

const Hero = () => {
  const { scrollY } = useScroll();
  const y1 = useTransform(scrollY, [0, 1000], [0, 200]);
  const opacity = useTransform(scrollY, [0, 500], [1, 0]);

  return (
    <section className="hero-container">
      <motion.div 
        className="hero-background"
        style={{ y: y1 }}
      >
        <div className="hero-overlay"></div>
        {/* Placeholder image, later can be a cinematic video or high-res photo */}
        <img src="https://images.unsplash.com/photo-1519741497674-611481863552?q=75&w=1200&auto=format&fit=crop" alt="Cinematic Wedding" className="hero-bg-image" />
      </motion.div>
      
      <div className="hero-content container">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.2 }}
        >
          <h1 className="hero-title">Every Love Story Deserves to Be Remembered.</h1>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.6 }}
        >
          <p className="hero-subtitle">From strangers... to soulmates... to forever.</p>
        </motion.div>
        
        <motion.div 
          className="hero-cta-group"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1 }}
        >
          <button className="btn-primary">See Our Stories</button>
          <button className="btn-secondary">Book Your Session</button>
        </motion.div>
      </div>

      <motion.div 
        className="scroll-indicator"
        style={{ opacity }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2, duration: 1 }}
      >
        <div className="scroll-line"></div>
      </motion.div>
    </section>
  );
};

export default Hero;
