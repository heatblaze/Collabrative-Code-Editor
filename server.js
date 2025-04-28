const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve static files (HTML, JS, CSS)
app.use(express.static('public'));

// When a client connects to the server
io.on('connection', (socket) => {
    console.log('A user connected');
    
    // Broadcast code updates to all other clients
    socket.on('code-update', (data) => {
        socket.broadcast.emit('code-update', data);
    });

    // Handle disconnect
    socket.on('disconnect', () => {
        console.log('A user disconnected');
    });
});

// Start the server on port 3000
server.listen(3000, () => {
    console.log('Server running on http://localhost:3000');
});
