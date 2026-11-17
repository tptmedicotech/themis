import { hashPassword } from '../src/lib/auth';
import { DEMO_READER_PASSWORD, DEMO_READERS } from '../src/lib/demo-readers';
import { openDatabase, seed } from '../src/lib/db';

const db = openDatabase();
const files = seed(db);

const upsert = db.transaction(() => {
  for (const reader of DEMO_READERS) {
    db.prepare('delete from themis_sessions where user_id = ?').run(reader.id);
    db.prepare('delete from themis_users where id = ? or email = ?').run(reader.id, reader.email);
    db.prepare(
      `insert into themis_users (id, email, password_hash, display_name, role, active)
       values (?, ?, ?, ?, 'reader', 1)`,
    ).run(reader.id, reader.email, hashPassword(DEMO_READER_PASSWORD), reader.displayName);
  }
});
upsert();

console.log(`seeded ${files.join(', ')}`);
console.log(`seeded ${DEMO_READERS.length} readers`);
db.close();
