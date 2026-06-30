import React, { useState } from 'react';
import { db } from '../firebase';
import { collection, addDoc, serverTimestamp } from 'firebase/firestore';
import { motion } from 'framer-motion';
import './Contact.css';

const Contact = () => {
  const [formData, setFormData] = useState({
    names: '',
    email: '',
    phone: '',
    eventDetails: '',
    story: ''
  });
  const [status, setStatus] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus('sending');
    try {
      await addDoc(collection(db, 'queries'), {
        ...formData,
        createdAt: serverTimestamp(),
        status: 'new'
      });
      setStatus('success');
      setFormData({ names: '', email: '', phone: '', eventDetails: '', story: '' });
      setTimeout(() => setStatus(''), 5000);
    } catch (error) {
      console.error("Error adding document: ", error);
      setStatus('error');
    }
  };

  return (
    <section id="contact" className="contact-section section-padding">
      <div className="container">
        <div className="contact-wrapper">
          <motion.div 
            className="contact-info"
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            <h2>Let's Create Something Beautiful Together.</h2>
            <p>Ready to start your journey? Reach out to us and let's preserve your memories.</p>
            
            <div className="contact-methods">
              <a href="https://wa.me/1234567890" target="_blank" rel="noreferrer" className="btn-primary" style={{ display: 'block', textAlign: 'center', margin: '0 auto 20px auto' }}>
                WhatsApp Us
              </a>
              <a href="mailto:aniruddhakapale560@gmail.com" className="btn-secondary" style={{ display: 'block', textAlign: 'center', margin: '0 auto' }}>
                aniruddhakapale560@gmail.com
              </a>
            </div>
          </motion.div>
          
          <motion.div 
            className="contact-form-container"
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <form className="contact-form" onSubmit={handleSubmit}>
              <div className="form-group">
                <input type="text" name="names" value={formData.names} onChange={handleChange} placeholder="Your Names" required />
              </div>
              <div className="form-group">
                <input type="email" name="email" value={formData.email} onChange={handleChange} placeholder="Email Address" required />
              </div>
              <div className="form-group">
                <input type="tel" name="phone" value={formData.phone} onChange={handleChange} placeholder="Phone Number" required />
              </div>
              <div className="form-group">
                <input type="text" name="eventDetails" value={formData.eventDetails} onChange={handleChange} placeholder="Event Date & Location" required />
              </div>
              <div className="form-group">
                <textarea name="story" value={formData.story} onChange={handleChange} placeholder="Tell us about your story..." rows="5" required></textarea>
              </div>
              <button type="submit" className="btn-primary" style={{ width: '100%' }} disabled={status === 'sending'}>
                {status === 'sending' ? 'Sending...' : 'Send Message'}
              </button>
              {status === 'success' && <p style={{ color: 'var(--accent-gold)', marginTop: '10px', textAlign: 'center' }}>Message sent successfully! We'll get back to you soon.</p>}
              {status === 'error' && <p style={{ color: 'red', marginTop: '10px', textAlign: 'center' }}>Failed to send message. Please try again.</p>}
            </form>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default Contact;
