# Project BIT Work Journal

This journal records session history for context retrieval: what we last worked on, decisions made, validation performed, and useful next steps. The [Game Bible](Project_BIT_Game_Bible_v0_1.md) remains the source for the overall vision and intended game mechanics.

## October 4, 2026 — Dashboard and playable monthly loop

**Time recorded: 1.25 hours (75 minutes), as specified by the user.**

### Starting point

Reviewed the v0.1 Game Bible and began with a fresh Godot 4.6 project in `project-bit/`, with no gameplay scenes. The session focused on building a playable 2D dashboard prototype.

### Work completed

- Created the main dashboard scene and configured the project to start fullscreen in January 1980 with $100 and no holdings.
- Added the date at top left, wealth at top right, financial overview, scrolling news, and Advance Month control.
- Labeled the current setting **Real World Timeline**; fictional and alternate historical timeline switching remains planned.
- Added a 12-month calendar strip with year, season colors, and a diamond marking the current month.
- Built stock and real estate charts with series selectors, 1Y/3Y/5Y ranges, date axes, and hover values. Prices and indices remain illustrative.
- Implemented buying/selling through pending orders: shared cash reservations, reserved holdings, cancellation, settlement, and updated net worth.
- Made stock orders settle next month and property transactions take seasonal closing delays, with commercial property taking an extra month. Quotes and closing dates lock at submission for this prototype.
- Initially built a combined Portfolio window, then replaced it with separate stock and real estate trading windows, each opened from its chart's **Buy / Sell & Queue** button. Each displays only its own holdings and queue.
- Split Visibility into combined FBI/IRS federal heat and criminal organization heat. Federal heat responds to settled transactions; criminal heat remains inactive until sports betting exists.
- Moved Visibility into its own dashboard panel, separate from Advance Month.
- Added a taller, scrolling action summary inside Advance Month, showing pending counts, next-turn settlements, quantities, values, and closing dates. Stock buys/sells and property buys/sells have distinct colors and text labels.

### Historical archive work

- Inspected v0.1: 60 monthly files covering 1980-1984 with 183 events.
- Paused integration while the user had ChatGPT expand the archive.
- Inspected v0.2 and clarified that its 1,080 records comprise **183 discrete events and 897 monthly context records**, not 1,080 distinct events.
- Confirmed 18 records per month, three for each of six topics: economics/markets, business/technology, politics/geopolitics, sports, pop culture, and society/science/disasters.
- After user authorization, connected v0.2 monthly JSON files to the news feed. Added topic/player-activity filtering, event/context labels, importance ordering, source details on hover, and missing-coverage notices.
- The displayed news is a **month-end review of the current month**, including January at startup. Future betting requires separate pre-result reveal rules. News metadata does not change prices.
- The active archive is `project-bit/project_bit_history_1980_1984_v0.2/project_bit_history_1980_1984_v0.2/`. The v0.1 folder remains present but unused by the loader.

### Documentation and verification

- Reconciled the Game Bible with implemented mechanics, JSON conventions, dashboard layout, provisional rules, and outstanding decisions. Updated the project README with controls and implementation notes.
- Ran Godot headless startup and simulation/UI checks during development. Checks covered order reservations, insufficient funds, overselling, cancellation, stock/property settlement, seasonal delays, independent heat behavior, window creation, and dashboard refresh.
- Checked all 60 archive months and 1,080 records, topic counts, source references, missing coverage, news filtering, and month advancement. Structural review found no duplicate record IDs or missing source references; historical accuracy was not independently verified.
- Ran whitespace/diff checks. Godot emitted an environment root-certificate-store warning; gameplay checks completed successfully. An early editor import could not save global editor settings under sandbox permissions.
- No rendered screenshot review or full visual QA was performed. Layout changes still benefit from an interactive playthrough at the intended screen resolution.

### Files to resume from

| File | Responsibility |
| --- | --- |
| `project-bit/dashboard.tscn` | Main scene |
| `project-bit/dashboard.gd` | Dashboard layout, monthly flow, news, heat display, and action summary |
| `project-bit/simulation.gd` | Shared finances, reservations, settlement, prices, and heat |
| `project-bit/trade_desk.gd` | Separate stock/property trading windows |
| `project-bit/market_chart.gd` | Chart rendering and hover values |
| `project-bit/calendar_strip.gd` | Seasonal calendar and current-month marker |
| `project-bit/history_archive.gd` | v0.2 monthly JSON loader and source references |
| `project-bit/verify_simulation.gd` | Headless simulation, archive, and UI checks |
| `project-bit/README.md` | Run instructions and current prototype behavior |

### Handoff / next-session context

The latest gameplay change was the color-coded pending-action summary inside Advance Month. The latest documentation change was a broader Game Bible reconciliation, followed by creation of this journal.

Useful follow-up work, not yet committed scope:

- Play through the dashboard in Godot (**F5**) and inspect sizing, scrolling, and window navigation with several queued orders.
- Decide save/load behavior; current runs are in memory only.
- Obtain historical financial data before replacing illustrative market curves.
- Define sports betting cutoffs and result visibility before implementing wagers or criminal heat.
- Plan archive coverage beyond December 1984, timeline switching, and whether players should browse past months' news.

For future exports, include `*.json` in Godot's non-resource export filter so the archive is packaged. Timeline switching, betting, investigations, financial costs/income systems, and save/load were not implemented this session.
