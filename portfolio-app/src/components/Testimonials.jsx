import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft, ChevronRight, Star } from 'lucide-react';
import './Testimonials.css';

const testimonials = [
  {
    id: 1,
    name: "Sarah & David",
    role: "Wedding Session",
    image: "https://images.unsplash.com/photo-1522851142566-1c05d7b57b98?q=70&w=150&auto=format&fit=crop",
    quote: "Antigravity didn't just take pictures; they captured the absolute magic of our wedding. Every time we look at our photos, we are transported right back to that day."
  },
  {
    id: 2,
    name: "Aisha & Kabir",
    role: "Pre-Wedding Session",
    image: "https://images.unsplash.com/photo-1542031536-1e438bd233d4?q=70&w=150&auto=format&fit=crop",
    quote: "Working with them was an absolute dream. They made us feel so comfortable, and the final photos look like stills from a classic romance film."
  },
  {
    id: 3,
    name: "Meera & Rohan",
    role: "Engagement Session",
    image: "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=70&w=150&auto=format&fit=crop",
    quote: "The dedication to storytelling and lighting is unparalleled. We are forever grateful for these stunning visual memories."
  }
];

const Testimonials = () => {
  const [current, setCurrent] = useState(0);

  const next = () => setCurrent((prev) => (prev === testimonials.length - 1 ? 0 : prev + 1));
  const prev = () => setCurrent((prev) => (prev === 0 ? testimonials.length - 1 : prev - 1));

  return (
    <section className="testimonials-section section-padding">
      <div className="container">
        <div className="testimonials-carousel">
          <AnimatePresence mode="wait">
            <motion.div
              key={current}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.1 }}
              transition={{ duration: 0.6 }}
              className="testimonial-card"
            >
              <div className="testimonial-image">
                <img src={testimonials[current].image} alt={testimonials[current].name} />
              </div>
              <div className="testimonial-content">
                <div className="stars">
                  {[...Array(5)].map((_, i) => <Star key={i} size={20} fill="var(--accent-gold)" color="var(--accent-gold)" />)}
                </div>
                <p className="quote">"{testimonials[current].quote}"</p>
                <h3 className="author">- {testimonials[current].name}</h3>
              </div>
            </motion.div>
          </AnimatePresence>
          
          <div className="carousel-controls">
            <button onClick={prev} className="carousel-btn"><ChevronLeft size={24} /></button>
            <button onClick={next} className="carousel-btn"><ChevronRight size={24} /></button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
