import React from 'react';
import './Navbar.css'; // We will create this

const Navbar = () => {
  return (
    <nav className="navbar">
      <div className="container nav-content">
        <div className="logo">
          Aniruddhakapale
        </div>
        <div className="nav-links">
          <a href="#stories">Our Stories</a>
          <a href="#services">Services</a>
          <a href="#about">Behind The Lens</a>
        </div>
        <button className="btn-primary nav-book-btn">Book Your Session</button>
      </div>
    </nav>
  );
};

export default Navbar;
