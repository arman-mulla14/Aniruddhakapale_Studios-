import React, { useEffect, useState } from 'react';
import { db } from '../firebase';
import { collection, getDocs, query, orderBy } from 'firebase/firestore';
import { motion } from 'framer-motion';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Pagination, EffectFade, Autoplay } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';
import 'swiper/css/effect-fade';
import './StoryTimeline.css';

const defaultChapters = [
  {
    id: '1',
    title: "Chapter 1",
    subtitle: "Two strangers meet.",
    description: "The beginning of everything. A glance, a smile, a connection that feels inevitable.",
    images: ["https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=70&w=600&auto=format&fit=crop"]
  },
  {
    id: '2',
    title: "Chapter 2",
    subtitle: "Coffee dates. Laughter. Tiny memories.",
    description: "Building a world together, one cup of coffee at a time.",
    images: ["https://images.unsplash.com/photo-1517462964-21fdcec3f25b?q=70&w=600&auto=format&fit=crop"]
  },
  {
    id: '3',
    title: "Chapter 3",
    subtitle: "The proposal.",
    description: "A single question that changes everything.",
    images: ["https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=70&w=600&auto=format&fit=crop"]
  },
  {
    id: '4',
    title: "Chapter 4",
    subtitle: "Engagement.",
    description: "Golden-hour photography capturing the promise of tomorrow.",
    images: ["https://images.unsplash.com/photo-1518049362265-d5b2a6467637?q=70&w=600&auto=format&fit=crop"]
  },
  {
    id: '5',
    title: "Chapter 5",
    subtitle: "Wedding Day.",
    description: "Large cinematic moments. Confetti, tears, and vows.",
    images: ["https://images.unsplash.com/photo-1606800052052-a08af7148866?q=70&w=600&auto=format&fit=crop"]
  },
  {
    id: '6',
    title: "Chapter 6",
    subtitle: "Their Forever.",
    description: "Family photos. Baby photos. Future memories.",
    images: ["https://images.unsplash.com/photo-1511895426328-dc8714191300?q=70&w=600&auto=format&fit=crop"]
  }
];

const StoryTimeline = () => {
  const [chapters, setChapters] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStories = async () => {
      try {
        const q = query(collection(db, 'stories'), orderBy('order', 'asc'));
        const snapshot = await getDocs(q);
        if (!snapshot.empty) {
          const storiesData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
          setChapters(storiesData);
        } else {
          setChapters(defaultChapters);
        }
      } catch (error) {
        console.error("Error fetching stories:", error);
        setChapters(defaultChapters);
      } finally {
        setLoading(false);
      }
    };
    
    fetchStories();
  }, []);

  return (
    <section id="stories" className="timeline-section section-padding">
      <div className="container">
        <motion.div 
          className="timeline-header"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8 }}
        >
          <h2>Our Stories</h2>
          <p>Let's See How Love Looks</p>
        </motion.div>

        <div className="timeline-container">
          {loading ? (
            <div style={{ textAlign: 'center', color: 'var(--accent-gold)' }}>Loading stories...</div>
          ) : (
            chapters.map((chapter, index) => (
              <motion.div 
                key={chapter.id}
                className={`timeline-item ${index % 2 === 0 ? 'left' : 'right'}`}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-100px" }}
                transition={{ duration: 0.8, delay: 0.2 }}
              >
                <div className="timeline-content">
                  <div className="chapter-meta">
                    <h3>{chapter.title}</h3>
                    <h4>{chapter.subtitle}</h4>
                    <p>{chapter.description}</p>
                  </div>
                  <div className="chapter-image">
                    {chapter.images && chapter.images.length > 0 ? (
                      <Swiper
                        modules={[Pagination, EffectFade, Autoplay]}
                        pagination={{ clickable: true }}
                        effect="fade"
                        autoplay={{ delay: 3000, disableOnInteraction: false }}
                        className="story-swiper"
                      >
                        {chapter.images.map((img, i) => (
                          <SwiperSlide key={i}>
                            <img src={img} alt={`${chapter.title} - ${i}`} loading="lazy" />
                          </SwiperSlide>
                        ))}
                      </Swiper>
                    ) : (
                      <div className="image-placeholder">No images available</div>
                    )}
                  </div>
                </div>
              </motion.div>
            ))
          )}
        </div>

        <motion.div 
          className="timeline-footer"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 1, delay: 0.5 }}
        >
          <h3>Now it's your turn to create memories.</h3>
          <button className="btn-primary">Let's Tell Your Story</button>
        </motion.div>
      </div>
    </section>
  );
};

export default StoryTimeline;
