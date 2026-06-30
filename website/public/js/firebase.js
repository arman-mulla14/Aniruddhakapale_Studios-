// Import the functions you need from the SDKs you need
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-analytics.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-storage.js";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCP7iGgrYSmLaojDR4KuzQRaOhBqeaQH_4",
  authDomain: "aniruddhakapale-4e51b.firebaseapp.com",
  projectId: "aniruddhakapale-4e51b",
  storageBucket: "aniruddhakapale-4e51b.firebasestorage.app",
  messagingSenderId: "691969489440",
  appId: "1:691969489440:web:5fa2ad7aee1d25a3631a45",
  measurementId: "G-KKFMBWRNWV"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);
const storage = getStorage(app);

export { app, analytics, db, auth, storage };
