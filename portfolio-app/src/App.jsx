import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import MomentDetail from './pages/MomentDetail';
import Navbar from './components/Navbar';
import Footer from './components/Footer';

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/moment/:id" element={<MomentDetail />} />
      </Routes>
      <Footer />
    </Router>
  );
}

export default App;
