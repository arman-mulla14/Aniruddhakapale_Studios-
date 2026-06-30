import React from 'react';
import { motion } from 'framer-motion';
import './Services.css';
import { Camera, Heart, Video, Star, Image as ImageIcon, Music } from 'lucide-react';

const services = [
  { id: 1, title: 'Wedding', description: 'Comprehensive coverage of your special day with a cinematic approach.', icon: <Camera size={32} /> },
  { id: 2, title: 'Pre-Wedding', description: 'Telling your love story before you say "I do" in beautiful locations.', icon: <Heart size={32} /> },
  { id: 3, title: 'Engagement', description: 'Capturing the surprise, the emotion, and the promise of forever.', icon: <Star size={32} /> },
  { id: 4, title: 'Couple Shoot', description: 'Intimate and natural portraits that reflect your unique connection.', icon: <ImageIcon size={32} /> },
  { id: 5, title: 'Cinematography', description: 'Wedding films that feel like a Hollywood masterpiece.', icon: <Video size={32} /> },
  { id: 6, title: 'Events', description: 'Preserving the energy and joy of your most important celebrations.', icon: <Music size={32} /> },
];

const Services = () => {
  return (
    <section id="services" className="services-section section-padding">
      <div className="container">
        <motion.div 
          className="services-header"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2>Our Services</h2>
          <p>Crafted With Passion</p>
        </motion.div>

        <div className="services-grid">
          {services.map((service, i) => (
            <motion.div
              key={service.id}
              className="service-card"
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.8, delay: i * 0.1 }}
            >
              <div className="service-icon">{service.icon}</div>
              <h3>{service.title}</h3>
              <p>{service.description}</p>
              <div className="service-hover-glow"></div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Services;
