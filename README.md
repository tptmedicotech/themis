# Themis

Themis is an internal monitor for tpt-api and tpt-webapp. A reader can read the local SQLite copy. A reader cannot change the copy.

Read these documents. Both use ASD-STE100.

- [docs/THEMIS-SPEC-STE100.md](docs/THEMIS-SPEC-STE100.md) is the application specification. Build the screens from that document.
- [docs/THEMIS-STYLE-STE100.md](docs/THEMIS-STYLE-STE100.md) is the visual style. Copy it from the tpt-webapp.
- [docs/THEMIS-STE100.md](docs/THEMIS-STE100.md) is the scaffold. It states the database, the seeds, and the read rule.

Run these commands from this folder:

```bash
pnpm install
pnpm db:migrate
pnpm db:seed
pnpm db:verify
pnpm dev
```

`pnpm dev` serves one page. The page states that the user interface is not in this cut.
