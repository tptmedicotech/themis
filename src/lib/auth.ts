import { createHash, randomBytes, scryptSync, timingSafeEqual } from 'node:crypto';
import type { Database } from 'better-sqlite3';

const SCRYPT_N = 16384;
const SCRYPT_R = 8;
const SCRYPT_P = 1;
const KEY_LEN = 32;

export type ReaderUser = {
  id: string;
  email: string;
  displayName: string;
  role: 'reader';
  active: number;
};

type UserRow = ReaderUser & { passwordHash: string };

export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString('hex');
  const hash = scryptSync(password, salt, KEY_LEN, {
    N: SCRYPT_N,
    r: SCRYPT_R,
    p: SCRYPT_P,
  }).toString('hex');
  return `scrypt$${SCRYPT_N}$${SCRYPT_R}$${SCRYPT_P}$${salt}$${hash}`;
}

export function verifyPassword(password: string, stored: string): boolean {
  const [algo, nRaw, rRaw, pRaw, salt, hash] = stored.split('$');
  if (algo !== 'scrypt' || !nRaw || !rRaw || !pRaw || !salt || !hash) return false;
  const actual = scryptSync(password, salt, KEY_LEN, {
    N: Number(nRaw),
    r: Number(rRaw),
    p: Number(pRaw),
  });
  const expected = Buffer.from(hash, 'hex');
  if (actual.length !== expected.length) return false;
  return timingSafeEqual(actual, expected);
}

export function findReaderByEmail(db: Database, email: string): UserRow | null {
  const row = db
    .prepare(
      `select id, email, display_name as displayName, role, active, password_hash as passwordHash
         from themis_users
        where email = ?`,
    )
    .get(email) as UserRow | undefined;
  if (!row || row.role !== 'reader' || row.active !== 1) return null;
  return row;
}

export function authenticate(db: Database, email: string, password: string): ReaderUser | null {
  const user = findReaderByEmail(db, email);
  if (!user || !verifyPassword(password, user.passwordHash)) return null;
  return {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    role: 'reader',
    active: user.active,
  };
}

export function createSession(
  db: Database,
  userId: string,
  ttlHours = 12,
): { token: string; expiresAt: string } {
  const token = randomBytes(32).toString('base64url');
  const tokenHash = createHash('sha256').update(token).digest('hex');
  const expiresAt = new Date(Date.now() + ttlHours * 60 * 60 * 1000).toISOString();
  const id = randomBytes(16).toString('hex');
  db.prepare(
    `insert into themis_sessions (id, user_id, token_hash, expires_at) values (?, ?, ?, ?)`,
  ).run(id, userId, tokenHash, expiresAt);
  return { token, expiresAt };
}

export function readSessionUser(db: Database, token: string): ReaderUser | null {
  const tokenHash = createHash('sha256').update(token).digest('hex');
  const row = db
    .prepare(
      `select u.id, u.email, u.display_name as displayName, u.role, u.active, s.expires_at as expiresAt
         from themis_sessions s
         join themis_users u on u.id = s.user_id
        where s.token_hash = ?`,
    )
    .get(tokenHash) as (ReaderUser & { expiresAt: string }) | undefined;
  if (!row || row.role !== 'reader' || row.active !== 1) return null;
  if (Date.parse(row.expiresAt) <= Date.now()) return null;
  return {
    id: row.id,
    email: row.email,
    displayName: row.displayName,
    role: 'reader',
    active: row.active,
  };
}
