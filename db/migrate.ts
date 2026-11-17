import { migrate, openDatabase } from '../src/lib/db';

const db = openDatabase();
const ran = migrate(db);
if (ran.length === 0) {
  console.log('migrations already applied');
} else {
  console.log(`applied ${ran.join(', ')}`);
}
db.close();
