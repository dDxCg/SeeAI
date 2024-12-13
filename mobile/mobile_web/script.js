// script.js

const video = document.getElementById('video');
const captureButton = document.getElementById('capture');
const photoContainer = document.getElementById('photo');
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');

// Khởi tạo camera
navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => {
        video.srcObject = stream;
    })
    .catch(error => {
        console.error("Không thể truy cập camera", error);
    });

// Chụp ảnh khi nhấn nút
captureButton.addEventListener('click', () => {
    // Thiết lập kích thước canvas giống như video
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    // Vẽ khung hình từ video lên canvas
    context.drawImage(video, 0, 0, canvas.width, canvas.height);

    // Chuyển canvas thành ảnh
    const dataURL = canvas.toDataURL('image/png');

    // Hiển thị ảnh lên trang web
    const img = document.createElement('img');
    img.src = dataURL;
    photoContainer.innerHTML = '';
    photoContainer.appendChild(img);
});
