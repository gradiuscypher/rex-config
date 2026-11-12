# Agent instructions

- Installation and shortcuts: [README.md](README.md).
- Before manipulating Rex sessions, panes, hosts, or connected apps, load the installed Rex skill and follow its generated guide; without a skill, run `rex skill show` first.
- Before editing `init.lua` or reasoning about Rex architecture, read [docs/rex.md](docs/rex.md).
- This repository is public. Keep committed content portable; exclude secrets, personal absolute paths, host inventories, session IDs, terminal captures, and other local runtime state.
- Validate config edits with `rex config check init.lua` from the repository root. Do not install, reload, or modify live Rex state just to verify an edit.
