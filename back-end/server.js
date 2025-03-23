const express = require ('express');
const dotenv = require('dotenv').config();
const PORT = process.env.PORT || 3001;
const server = express();


server.use(express.json());





server.listen(PORT, console.log(`Server is running on port ${PORT}`)
);