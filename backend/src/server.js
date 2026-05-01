const createApp = require('./app');
const env = require('./config/env');

const app = createApp();

app.listen(env.port, () => {
  console.log(`Smart Attendance API running on port ${env.port}`);
});
