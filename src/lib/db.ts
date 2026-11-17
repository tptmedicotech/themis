import { mkdirSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import Database from 'better-sqlite3';

const here = dirname(fileURLToPath(import.meta.url));
export const THEMIS_ROOT = join(here, '..', '..');
export const MIGRATIONS_DIR = join(THEMIS_ROOT, 'db', 'migrations');
export const SEEDS_DIR = join(THEMIS_ROOT, 'db', 'seeds');
export const UPSTREAM_DIR = join(THEMIS_ROOT, 'db', 'upstream');

export function databasePath(): string {
  return process.env.THEMIS_DATABASE_PATH
    ? join(THEMIS_ROOT, process.env.THEMIS_DATABASE_PATH)
    : join(THEMIS_ROOT, 'data', 'themis.sqlite');
}

export function openDatabase(): Database.Database {
  const path = databasePath();
  mkdirSync(dirname(path), { recursive: true });
  const db = new Database(path);
  db.pragma('foreign_keys = ON');
  db.pragma('journal_mode = WAL');
  return db;
}

export function listSqlFiles(dir: string): string[] {
  return readdirSync(dir)
    .filter((name) => name.endsWith('.sql'))
    .sort();
}

export function migrate(db: Database.Database, dir = MIGRATIONS_DIR): string[] {
  db.exec(`
    create table if not exists schema_migrations (
      id text primary key,
      applied_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
    )
  `);
  const applied = new Set(
    (db.prepare('select id from schema_migrations').all() as Array<{ id: string }>).map((row) => row.id),
  );
  const ran: string[] = [];
  for (const file of listSqlFiles(dir)) {
    if (applied.has(file)) continue;
    const body = readFileSync(join(dir, file), 'utf8');
    const apply = db.transaction(() => {
      db.exec(body);
      db.prepare('insert into schema_migrations (id) values (?)').run(file);
    });
    try {
      apply();
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new Error(`migration ${file} failed: ${message}`);
    }
    ran.push(file);
  }
  return ran;
}

export function seed(db: Database.Database, dir = SEEDS_DIR): string[] {
  const ran: string[] = [];
  for (const file of listSqlFiles(dir)) {
    const body = readFileSync(join(dir, file), 'utf8');
    const apply = db.transaction(() => {
      db.exec(body);
    });
    try {
      apply();
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new Error(`seed ${file} failed: ${message}`);
    }
    ran.push(file);
  }
  return ran;
}
