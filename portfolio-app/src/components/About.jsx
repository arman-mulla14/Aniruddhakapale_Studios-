import React from 'react';
import { motion } from 'framer-motion';
import './About.css';

const About = () => {
  return (
    <section id="about" className="about-section section-padding">
      <div className="container">
        <div className="about-content-wrapper">
          <motion.div 
            className="about-image-container"
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 1 }}
          >
            <img src="https://images.unsplash.com/photo-1554046920-90dcac824ab1?q=75&w=1000&auto=format&fit=crop" alt="Photographer" className="about-image" />
          </motion.div>
          
          <motion.div 
            className="about-text-container"
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 1, delay: 0.2 }}
          >
            <h2>Behind The Lens</h2>
            <p className="about-quote">"I don't believe photography is about cameras. It's about emotions."</p>
            
            <div className="about-details">
              <p>The smile your parents gave you.</p>
              <p>The tears during your vows.</p>
              <p>The laughter you'll remember twenty years later.</p>
              <p className="highlight">Those are the moments I live to capture.</p>
            </div>
            
            <button className="btn-secondary" style={{ marginTop: '30px' }}>Meet The Team</button>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default About;
