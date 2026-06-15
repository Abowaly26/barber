import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBYIvoEAaPyKHYH6YtW8lSmRtQGW8zysRc",
  authDomain: "barber-10ed3.firebaseapp.com",
  projectId: "barber-10ed3",
  storageBucket: "barber-10ed3.firebasestorage.app",
  messagingSenderId: "669260082445",
  appId: "1:669260082445:web:ae2b5f662783b356b45444",
  measurementId: "G-R8VBNL53HH"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;
