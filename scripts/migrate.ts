import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { Client } from 'pg';

const PG_USER = process.env.POSTGRES_USER;
const PG_PASSWORD = process.env.POSTGRES_PASSWORD;
const PG_HOST = process.env.POSTGRES_HOST;
const PG_PORT : number | undefined = process.env.POSTGRES_PORT ? parseInt(process.env.POSTGRES_PORT) : undefined;
const DB_NAME = process.env.POSTGRES_NAME;

async function createDatabaseIfNotExists() {
  const client = new Client({
    user: PG_USER,
    password: PG_PASSWORD,
    host: PG_HOST,
    port: PG_PORT,
    database: 'postgres', 
  });

  await client.connect();

  const res = await client.query(
    `SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'`
  );

  if (res.rowCount === 0) {
    await client.query(`CREATE DATABASE ${DB_NAME}`);
  } else {
    console.log(`Database ${DB_NAME} already exists.`);
  }

  await client.end();
}

async function migrations() {
  const client = new Client({
    user: PG_USER,
    password: PG_PASSWORD,
    host: PG_HOST,
    port: PG_PORT,
    database: DB_NAME,
  });

  await client.connect();

  const migrationsDir = join(process.cwd(), '/server/src/db/migrations');
  const files = readdirSync(migrationsDir).filter(f => f.endsWith('.sql'));

  for (const file of files) {
    const sql = readFileSync(join(migrationsDir, file), 'utf8');
    console.log(`Running migration: ${file}`);
    await client.query(sql);
  }

  await client.end();
  console.log('All migrations applied successfully!');
}

createDatabaseIfNotExists()
  .then(migrations)
  .catch(err => {
    console.error('[DB-ERROR] Migration failed:', err);
    process.exit(1);
  });