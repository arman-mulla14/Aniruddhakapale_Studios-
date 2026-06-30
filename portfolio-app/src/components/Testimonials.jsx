import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft, ChevronRight, Star } from 'lucide-react';
import './Testimonials.css';

const testimonials = [
  {
    id: 1,
    name: "Sarah & James",
    quote: "They didn't just take photos. They captured the very essence of our love. Every time I look at our album, I cry.",
    image: "https://images.unsplash.com/photo-1522851142566-1c05d7b57b98?q=80&w=2070&auto=format&fit=crop"
  },
  {
    id: 2,
    name: "Priya & Rahul",
    quote: "A truly cinematic experience. They made us feel like movie stars on our wedding day. Absolutely premium service.",
    image: "https://images.unsplash.com/photo-1542031536-1e438bd233d4?q=80&w=1974&auto=format&fit=crop"
  },
  {
    id: 3,
    name: "Emma & Michael",
    quote: "The best decision we made for our wedding. The attention to detail and storytelling is unmatched.",
    image: "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop"
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
