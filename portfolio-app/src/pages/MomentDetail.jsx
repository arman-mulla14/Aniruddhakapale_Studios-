import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { db } from '../firebase';
import { doc, getDoc } from 'firebase/firestore';
import './MomentDetail.css';

// Default static fallbacks for moments so the page is fully working even if DB is empty
const defaultMomentsFallback = {
  '1': {
    title: "The First Dance",
    location: "Mumbai",
    date: "Oct 2025",
    description: "A beautiful evening captured in Mumbai. The soft lights, the swirling gown, and the quiet glance that shared a lifetime promise.",
    coverImage: "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop"
    ]
  },
  '2': {
    title: "Vows",
    location: "Goa",
    date: "Dec 2025",
    description: "Whispered promises against the ocean breeze. A serene and emotional ceremony set on the sandy beaches of South Goa.",
    coverImage: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1507504038482-7621c5f606a0?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=2070&auto=format&fit=crop"
    ]
  },
  '3': {
    title: "Joy",
    location: "Jaipur",
    date: "Nov 2025",
    description: "Laughter that echoed through the royal corridors. Celebrating a colorful pre-wedding sangeet filled with dance and endless smiles.",
    coverImage: "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=2069&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1511895426328-dc8714191300?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2070&auto=format&fit=crop"
    ]
  },
  '4': {
    title: "Together",
    location: "Kerala",
    date: "Jan 2026",
    description: "Quiet mornings on backwaters, capturing the stillness of a couple beginning a journey of eternity in God's Own Country.",
    coverImage: "https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2070&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1507504038482-7621c5f606a0?q=80&w=2070&auto=format&fit=crop"
    ]
  },
  '5': {
    title: "Golden Hour",
    location: "Udaipur",
    date: "Feb 2026",
    description: "Sunsets reflecting off Lake Pichola. A luxury pre-wedding shoot wrapped in warm, romantic, cinematic lighting.",
    coverImage: "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=2069&auto=format&fit=crop"
    ]
  },
  '6': {
    title: "Forever",
    location: "Pune",
    date: "Mar 2026",
    description: "An intimate and elegant modern engagement, capturing details of raw laughter, tears, and rings that symbolize forever.",
    coverImage: "https://images.unsplash.com/photo-1606214174585-f8f40733816a?q=80&w=2070&auto=format&fit=crop",
    galleryImages: [
      "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1511895426328-dc8714191300?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop"
    ]
  }
};

const MomentDetail = () => {
  const { id } = useParams();
  const [moment, setMoment] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    window.scrollTo(0, 0);
    const fetchMoment = async () => {
      try {
        const docRef = doc(db, "moments", id);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
          setMoment(docSnap.data());
        } else {
          // Check if it's one of our fallback keys
          if (defaultMomentsFallback[id]) {
            setMoment(defaultMomentsFallback[id]);
          } else {
            console.log("No such document!");
          }
        }
      } catch (error) {
        console.error("Error fetching moment:", error);
        // Attempt fallback even on fetch error to ensure it works offline/locally
        if (defaultMomentsFallback[id]) {
          setMoment(defaultMomentsFallback[id]);
        }
      } finally {
        setLoading(false);
      }
    };

    fetchMoment();
  }, [id]);

  if (loading) {
    return (
      <div className="moment-detail-loading">
        <div className="spinner"></div>
      </div>
    );
  }

  if (!moment) {
    return (
      <div className="moment-detail-error">
        <h2>Moment not found</h2>
        <Link to="/" className="back-link">Return to Home</Link>
      </div>
    );
  }

  return (
    <main className="moment-detail-page">
      <section className="moment-hero">
        <div className="moment-hero-bg" style={{ backgroundImage: `url(${moment.coverImage})` }}></div>
        <div className="moment-hero-overlay"></div>
        <motion.div 
          className="moment-hero-content container"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1 }}
        >
          <Link to="/" className="back-btn">&larr; Back to Gallery</Link>
          <h1>{moment.title}</h1>
          <p className="moment-meta">{moment.location} &bull; {moment.date}</p>
          {moment.description && <p className="moment-desc">{moment.description}</p>}
        </motion.div>
      </section>

      {moment.galleryImages && moment.galleryImages.length > 0 && (
        <section className="moment-gallery-section section-padding">
          <div className="container">
            <div className="moment-masonry">
              {moment.galleryImages.map((src, index) => (
                <motion.div 
                  key={index} 
                  className="moment-masonry-item"
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true, margin: "-50px" }}
                  transition={{ duration: 0.6, delay: index * 0.1 }}
                >
                  <img src={src} alt={`${moment.title} gallery ${index}`} loading="lazy" />
                </motion.div>
              ))}
            </div>
          </div>
        </section>
      )}
    </main>
  );
};

export default MomentDetail;
