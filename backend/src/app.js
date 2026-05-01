const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const authRoutes = require('./routes/authRoutes');
const catalogRoutes = require('./routes/catalogRoutes');
const teacherRoutes = require('./routes/teacherRoutes');
const studentRoutes = require('./routes/studentRoutes');

function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());

  app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
  });

  app.use('/auth', authRoutes);
  app.use('/catalog', catalogRoutes);
  app.use('/teacher', teacherRoutes);
  app.use('/student', studentRoutes);

  app.use((_req, res) => {
    res.status(404).json({ message: 'Route not found' });
  });

  app.use((error, _req, res, _next) => {
    const status = error.status || 500;
    const message = status === 500 ? 'Internal server error' : error.message;

    if (status === 500) {
      console.error(error);
    }

    res.status(status).json({ message });
  });

  return app;
}

module.exports = createApp;
