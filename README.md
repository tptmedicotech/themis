# Themis

Themis is an internal monitor scaffold. This cut stores a SQLite copy of tpt-api data and tpt-webapp usage. This cut does not include the user interface.

Read [docs/THEMIS-STE100.md](docs/THEMIS-STE100.md). That document is the work instruction. The document uses ASD-STE100.

Run these commands from this folder:

```bash
pnpm install
pnpm db:migrate
pnpm db:seed
pnpm db:verify
pnpm dev
```

`pnpm dev` serves one page. The page states that the user interface is not in this cut.
