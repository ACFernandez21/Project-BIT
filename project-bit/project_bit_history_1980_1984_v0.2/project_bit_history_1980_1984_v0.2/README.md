# Project BIT Historical Timeline — 1980–1984

Version: **0.2.0**

Coverage: **60 months / 1,080 historical records / exactly 18 records per month**.

Each month targets exactly three records in each of six topic classes:

1. `economics_markets`
2. `business_technology`
3. `politics_geopolitics`
4. `sports`
5. `pop_culture`
6. `society_science_disasters`

## Important distinction: event vs monthly context

This version deliberately avoids manufacturing fake exact dates just to reach 18 items.

- `record_type: "event"` = a discrete historical event with a specific historical anchor.
- `record_type: "monthly_context"` = an ongoing historically grounded condition, trend, season, or background story useful to Project BIT.

Current mix:
- discrete events retained from v0.1: **183**
- monthly context anchors: **897**

This makes the pack immediately useful as an 18-hook-per-turn gameplay dataset while clearly telling Codex which records are safe to treat as discrete events.

## Game integration

Suggested Godot path:

`res://data/history/1983/1983-06.json`

Recommended behavior:
- News UI: prefer `record_type == "event"` and higher `importance`.
- Background/news chatter: freely use `monthly_context`.
- Market explanation: use `game_relevance` and `economic_sectors` as hints only.
- Historical price simulation: actual price/economic datasets remain authoritative.
- Save-game references: use stable `id`.

## Validation

The generated pack was checked for:
- 60 monthly files
- exactly 18 records in every month
- exactly 3 records per topic class per month
- unique IDs inside the master set
- valid `importance` range
- explicit `record_type`

## Research note

This is still a **game-development research baseline**, not a scholarly exhaustive chronology. Federal Reserve History and NBER material ground the macroeconomic arc. Yearly U.S./world chronology sources provide broad event cross-checking.

A later v0.3 research pass should replace additional `monthly_context` records with discrete sourced events, particularly company news, product releases, stock/commodity events, chart/music milestones, film releases, and specific sports results.
