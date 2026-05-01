const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

// Load .env from current directory
const envPath = path.join(__dirname, '.env');
dotenv.config({ path: envPath });

async function initDb() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  });

  try {
    console.log('Connected to MySQL. Initializing database...');
    
    const schemaSql = fs.readFileSync(path.join(__dirname, 'database', 'schema.sql'), 'utf8');
    const seedSql = fs.readFileSync(path.join(__dirname, 'database', 'seed.sql'), 'utf8');

    await connection.query(schemaSql);
    console.log('Schema applied successfully.');

    await connection.query(seedSql);
    console.log('Seed data applied successfully.');

  } catch (error) {
    console.error('Error during DB initialization:', error);
  } finally {
    await connection.end();
  }
}

initDb();
