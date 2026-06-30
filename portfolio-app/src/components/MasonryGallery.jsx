import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { db } from '../firebase';
import { collection, getDocs, query, orderBy } from 'firebase/firestore';
import './MasonryGallery.css';

const defaultImages = [
  { id: '1', coverImage: "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop", title: "The First Dance", location: "Mumbai", date: "Oct 2025" },
  { id: '2', coverImage: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop", title: "Vows", location: "Goa", date: "Dec 2025" },
  { id: '3', coverImage: "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop", title: "Joy", location: "Jaipur", date: "Nov 2025" },
  { id: '4', coverImage: "https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2070&auto=format&fit=crop", title: "Together", location: "Kerala", date: "Jan 2026" },
  { id: '5', coverImage: "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop", title: "Golden Hour", location: "Udaipur", date: "Feb 2026" },
  { id: '6', coverImage: "https://images.unsplash.com/photo-1606214174585-f8f40733816a?q=80&w=2070&auto=format&fit=crop", title: "Forever", location: "Pune", date: "Mar 2026" },
];

const MasonryGallery = () => {
  const [images, setImages] = useState(defaultImages);

  useEffect(() => {
    const fetchMoments = async () => {
      try {
        const q = query(collection(db, "moments"), orderBy("order", "desc"));
        const snapshot = await getDocs(q);
        if (!snapshot.empty) {
          const momentsData = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setImages(momentsData);
        }
      } catch (error) {
        console.error("Error fetching moments: ", error);
      }
    };

    fetchMoments();
  }, []);

  return (
    <section className="gallery-section section-padding">
      <div className="container">
        <motion.div 
          className="gallery-header"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2>Moments</h2>
          <p>Preserved for eternity</p>
        </motion.div>

        <div className="masonry-grid">
          {images.map((img, i) => (
            <motion.div 
              key={img.id}
              className="masonry-item"
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.8, delay: i * 0.1 }}
            >
              <Link to={`/moment/${img.id}`} className="gallery-card">
                <img src={img.coverImage} alt={img.title} loading="lazy" />
                <div className="gallery-overlay">
                  <div className="gallery-info">
                    <h3>{img.title}</h3>
                    <p>{img.location} &bull; {img.date}</p>
                  </div>
                </div>
              </Link>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default MasonryGallery;
