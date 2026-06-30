import { auth, db, storage } from '../../public/js/firebase.js';
import { onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";
import { collection, query, orderBy, onSnapshot } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";
import { ref, uploadBytesResumable, getDownloadURL } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-storage.js";

// 1. Auth Protection
onAuthStateChanged(auth, (user) => {
    if (!user) {
        window.location.href = 'index.html'; // Redirect to login if not authenticated
    }
});

const logoutBtn = document.getElementById('logoutBtn');
if (logoutBtn) {
    logoutBtn.addEventListener('click', (e) => {
        e.preventDefault();
        signOut(auth).then(() => {
            window.location.href = 'index.html';
        });
    });
}

// 2. Fetch Inquiries Realtime
const inquiriesContainer = document.getElementById('inquiriesContainer');
if (inquiriesContainer) {
    const q = query(collection(db, "inquiries"), orderBy("timestamp", "desc"));
    onSnapshot(q, (snapshot) => {
        inquiriesContainer.innerHTML = '';
        if (snapshot.empty) {
            inquiriesContainer.innerHTML = '<p>No inquiries found.</p>';
            return;
        }
        snapshot.forEach((doc) => {
            const data = doc.data();
            const date = data.timestamp ? data.timestamp.toDate().toLocaleDateString() : 'Just now';
            inquiriesContainer.innerHTML += `
                <div style="background: #160c1d; padding: 1rem; margin-bottom: 0.5rem; border-radius: 4px;">
                    <strong>${data.name}</strong> (${data.email}) - <span style="color:var(--color-secondary);">${data.service}</span><br>
                    <small style="color: #a69bb0;">${date}</small>
                    <p style="margin-top: 0.5rem;">${data.message}</p>
                </div>
            `;
        });
    });
}

// 3. Handle File Upload
const uploadForm = document.getElementById('uploadForm');
if (uploadForm) {
    uploadForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const file = document.getElementById('photoFile').files[0];
        const caption = document.getElementById('photoCaption').value;
        const category = document.getElementById('photoCategory').value;
        const statusMsg = document.getElementById('uploadStatus');

        if (!file) return;

        const storageRef = ref(storage, `portfolio/${category}/${file.name}`);
        const uploadTask = uploadBytesResumable(storageRef, file);

        uploadTask.on('state_changed', 
            (snapshot) => {
                const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                statusMsg.innerText = `Upload is ${Math.round(progress)}% done`;
            }, 
            (error) => {
                console.error("Upload error:", error);
                statusMsg.innerText = "Upload failed.";
                statusMsg.style.color = "#ff6b6b";
            }, 
            () => {
                getDownloadURL(uploadTask.snapshot.ref).then((downloadURL) => {
                    statusMsg.innerText = "Upload successful!";
                    statusMsg.style.color = "#e6e6fa";
                    uploadForm.reset();
                    // Optional: Save the downloadURL and metadata to Firestore here
                });
            }
        );
    });
}
