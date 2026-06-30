import React from 'react';
import Hero from '../components/Hero';
import StoryTimeline from '../components/StoryTimeline';
import MasonryGallery from '../components/MasonryGallery';
import Services from '../components/Services';
import About from '../components/About';
import Testimonials from '../components/Testimonials';
import Contact from '../components/Contact';

const Home = () => {
  return (
    <main>
      <Hero />
      <StoryTimeline />
      <MasonryGallery />
      <Services />
      <Testimonials />
      <About />
      <Contact />
    </main>
  );
};

export default Home;
