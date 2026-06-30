import { auth } from '../../public/js/firebase.js';
import { signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";

const loginForm = document.getElementById('loginForm');
const errorMsg = document.getElementById('errorMsg');

if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('adminEmail').value;
        const password = document.getElementById('adminPassword').value;
        const submitBtn = loginForm.querySelector('button[type="submit"]');
        
        submitBtn.innerText = "Logging in...";
        submitBtn.disabled = true;

        try {
            await signInWithEmailAndPassword(auth, email, password);
            window.location.href = 'dashboard.html';
        } catch (error) {
            console.error("Login failed:", error);
            errorMsg.innerText = "Invalid credentials. Please try again.";
            submitBtn.innerText = "Login to Dashboard";
            submitBtn.disabled = false;
        }
    });
}
