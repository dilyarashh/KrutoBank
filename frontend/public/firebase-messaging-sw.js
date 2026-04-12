importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAjWAM4he2_mDZo0fPUoSSlt-MgzXgTFGo',
  authDomain: 'krutobank.firebaseapp.com',
  projectId: 'krutobank',
  storageBucket: 'krutobank.firebasestorage.app',
  messagingSenderId: '516980630955',
  appId: '1:516980630955:web:9faf413186dbcf367a9eee',
  measurementId: 'G-7GT0L6MRM2',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'KrutoBank';
  const options = {
    body: payload.notification?.body,
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(clients.openWindow('/'));
});
