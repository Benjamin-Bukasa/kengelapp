const express = require('express'); 
const dotenv = require('dotenv'). config(); 
const cors = require('cors'); 
const authRoutes = require('./routes/auth.js');
const userRoutes = require('./routes/users.js');

// Create an instance of express
const server = express();

// Middleware setup
server.use(express.json());
server.use(cors());

// Routes to handle authentication
server.use('/kengelapp', authRoutes);

//Route to handle user data
server.use('/kengelapp', userRoutes);

// Start the server on port 5000
const PORT = process.env.PORT || 5001;
server.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});