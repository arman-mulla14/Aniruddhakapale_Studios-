import { db } from './firebase.js';
import { collection, addDoc, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";

// Main JavaScript - Animations and Interactions

document.addEventListener("DOMContentLoaded", () => {
    // 1. Initialize Lenis for Smooth Scrolling
    const lenis = new Lenis({
        duration: 1.2,
        easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        direction: 'vertical',
        gestureDirection: 'vertical',
        smooth: true,
        mouseMultiplier: 1,
        smoothTouch: false,
        touchMultiplier: 2,
        infinite: false,
    });

    // Setup Lenis to work with GSAP ScrollTrigger
    function raf(time) {
        lenis.raf(time);
        requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    // 2. Preloader Logic
    const preloader = document.querySelector('.preloader');
    setTimeout(() => {
        preloader.style.opacity = '0';
        setTimeout(() => {
            preloader.style.display = 'none';
            initAnimations(); // Start animations after preloader
        }, 1000);
    }, 1500);

    // 3. Header Scroll Effect
    const header = document.querySelector('.site-header');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.scrollY;

        // Add background when scrolled
        if (currentScroll > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }

        // Auto-hide header on scroll down (only if menu isn't open)
        const navLinks = document.getElementById('navLinks');
        const isMenuOpen = navLinks && navLinks.classList.contains('nav-active');

        if (currentScroll > lastScroll && currentScroll > 100 && !isMenuOpen) {
            // Scrolling down & past 100px
            header.classList.add('header-hidden');
        } else {
            // Scrolling up
            header.classList.remove('header-hidden');
        }

        lastScroll = currentScroll;
    });

    // Mobile Navigation Toggle
    const hamburger = document.getElementById('hamburger');
    const navLinks = document.getElementById('navLinks');
    const closeMenu = document.getElementById('closeMenu');
    
    if (hamburger && navLinks) {
        hamburger.addEventListener('click', () => {
            navLinks.classList.toggle('nav-active');
            hamburger.classList.toggle('is-active');
            
            // Toggle body scroll
            if (navLinks.classList.contains('nav-active')) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        });

        const closeNav = () => {
            navLinks.classList.remove('nav-active');
            hamburger.classList.remove('is-active');
            document.body.style.overflow = '';
        };

        if (closeMenu) {
            closeMenu.addEventListener('click', closeNav);
        }

        // Close menu when a link is clicked
        const navItems = document.querySelectorAll('.nav-links a');
        navItems.forEach(item => {
            item.addEventListener('click', closeNav);
        });
    }

    // 4. Portfolio Item Hover Setup
    const portfolioItems = document.querySelectorAll('.portfolio-item');
    portfolioItems.forEach(item => {
        item.addEventListener('mouseenter', () => {
            item.querySelector('.portfolio-overlay').style.opacity = '1';
        });
        item.addEventListener('mouseleave', () => {
            item.querySelector('.portfolio-overlay').style.opacity = '0';
        });
    });

    // 4.5 Portfolio Lightbox Gallery
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightboxImg');
    const lightboxClose = document.getElementById('lightboxClose');
    const lightboxPrev = document.getElementById('lightboxPrev');
    const lightboxNext = document.getElementById('lightboxNext');
    let currentImageIndex = 0;
    let portfolioImages = [];

    // Collect all portfolio images
    document.querySelectorAll('.portfolio-item img').forEach((img, index) => {
        portfolioImages.push(img.src);
        
        // When clicking an image, open lightbox
        img.parentElement.addEventListener('click', () => {
            currentImageIndex = index;
            openLightbox();
        });
    });

    function openLightbox() {
        if (!lightbox) return;
        lightbox.style.display = 'block';
        lightboxImg.src = portfolioImages[currentImageIndex];
        document.body.style.overflow = 'hidden';
    }

    function closeLightbox() {
        if (!lightbox) return;
        lightbox.style.display = 'none';
        document.body.style.overflow = '';
    }

    function changeImage(direction) {
        currentImageIndex += direction;
        if (currentImageIndex < 0) {
            currentImageIndex = portfolioImages.length - 1;
        } else if (currentImageIndex >= portfolioImages.length) {
            currentImageIndex = 0;
        }
        lightboxImg.src = portfolioImages[currentImageIndex];
    }

    if (lightboxClose) lightboxClose.addEventListener('click', closeLightbox);
    if (lightboxPrev) lightboxPrev.addEventListener('click', () => changeImage(-1));
    if (lightboxNext) lightboxNext.addEventListener('click', () => changeImage(1));

    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
        if (lightbox && lightbox.style.display === 'block') {
            if (e.key === 'Escape') closeLightbox();
            if (e.key === 'ArrowLeft') changeImage(-1);
            if (e.key === 'ArrowRight') changeImage(1);
        }
    });

    // 5. GSAP Animations
    function initAnimations() {
        gsap.registerPlugin(ScrollTrigger);

        // Hero Parallax
        gsap.to(".parallax-image", {
            yPercent: 20,
            ease: "none",
            scrollTrigger: {
                trigger: ".hero-section",
                start: "top top",
                end: "bottom top",
                scrub: true
            }
        });

        // Text Reveals
        const revealTexts = document.querySelectorAll('.reveal-text');
        revealTexts.forEach(text => {
            // Split text into lines/words/chars (Simple version without Splitting.js: just fade up for now, or use css class)
            gsap.fromTo(text, 
                { y: 50, opacity: 0 },
                { 
                    y: 0, 
                    opacity: 1, 
                    duration: 1, 
                    ease: "power3.out",
                    scrollTrigger: {
                        trigger: text,
                        start: "top 85%",
                    }
                }
            );
        });

        // Image Reveals
        const imageReveals = document.querySelectorAll('.image-reveal-wrapper');
        imageReveals.forEach(wrapper => {
            ScrollTrigger.create({
                trigger: wrapper,
                start: "top 80%",
                onEnter: () => wrapper.classList.add('is-revealed'),
                once: true
            });
        });

        // Staggered Portfolio Items
        gsap.fromTo(".portfolio-item", 
            { y: 100, opacity: 0 },
            { 
                y: 0, 
                opacity: 1, 
                duration: 0.8, 
                stagger: 0.2,
                ease: "power2.out",
                scrollTrigger: {
                    trigger: ".portfolio-grid",
                    start: "top 80%",
                }
            }
        );
    }

    // 6. Contact Form Submission
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const submitBtn = contactForm.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerText;
            submitBtn.innerText = "Sending...";
            submitBtn.disabled = true;

            const name = document.getElementById('contactName').value;
            const email = document.getElementById('contactEmail').value;
            const service = document.getElementById('contactService').value;
            const message = document.getElementById('contactMessage').value;

            try {
                await addDoc(collection(db, "inquiries"), {
                    name,
                    email,
                    service,
                    message,
                    timestamp: serverTimestamp(),
                    status: "new"
                });

                submitBtn.innerText = "Sent Successfully!";
                contactForm.reset();
                
                setTimeout(() => {
                    submitBtn.innerText = originalText;
                    submitBtn.disabled = false;
                }, 3000);

            } catch (error) {
                console.error("Error adding document: ", error);
                submitBtn.innerText = "Error. Try again.";
                submitBtn.disabled = false;
            }
        });
    }
});
