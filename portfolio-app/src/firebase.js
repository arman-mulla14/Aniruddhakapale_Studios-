import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyCP7iGgrYSmLaojDR4KuzQRaOhBqeaQH_4",
  authDomain: "aniruddhakapale-4e51b.firebaseapp.com",
  projectId: "aniruddhakapale-4e51b",
  storageBucket: "aniruddhakapale-4e51b.firebasestorage.app",
  messagingSenderId: "691969489440",
  appId: "1:691969489440:web:5fa2ad7aee1d25a3631a45",
  measurementId: "G-KKFMBWRNWV"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const storage = getStorage(app);

export { app, db, auth, storage };
