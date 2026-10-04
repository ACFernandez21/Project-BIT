# Project BIT - Game Bible (v0.1)

Last reconciled with the playable prototype: **October 4, 2026**. Bible/prototype version numbers are separate from historical archive versions; the active archive is **v0.2.0**. Sections marked current describe implemented behavior. Other systems describe design intent, not completed features.

## Overview

Project BIT is a historical financial simulation game in which the player is sent back in time with future knowledge and a small amount of starting capital.

The core fantasy is:

> "What could someone achieve financially if they knew the future?"

The current prototype starts in **January 1980 with $100 cash and no holdings**. The player attempts to accumulate as much wealth, influence, and long-term power as possible by exploiting historical knowledge. Other start years remain a future option.

The game combines:
- Financial simulation
- Historical education
- Strategic optimization
- Alternate history systems
- Risk management
- Suspicion / detection mechanics

---

# Core Design Philosophy

Project BIT is intended to:
- Teach players historical economic events through gameplay
- Create the fantasy of exploiting future knowledge
- Encourage understanding of compounding wealth
- Simulate market timing and investment strategy
- Force players to balance profit against visibility/suspicion

The game should feel like:
- A historical sandbox
- A financial strategy simulator
- A timeline manipulation engine
- A paranoia management game

---

# Core Gameplay Loop

1. Review current month/year
2. Read news/events/economic indicators
3. Allocate capital
4. Make investment or betting decisions
5. Observe market outcomes
6. Manage suspicion and investigations
7. Advance to next month
8. Repeat through history

---

# MVP Scope (Prototype 0.1)

The first playable prototype should prioritize:
- Spreadsheet-heavy simulation
- Minimal graphics
- Strong economic systems
- Fast iteration
- Historical event implementation

Original MVP targets (historical prices remain unimplemented):
- Monthly turn progression
- Historical stock market simulation
- Buy / Sell / Hold mechanics
- Cash management
- Net worth tracking
- Historical event timeline
- Basic suspicion system
- Basic news/event system

Current playable systems include the full-screen Godot 4.6 dashboard, illustrative market charts, separate stock/property trading windows, deferred order settlement, cash reservations, historical JSON news, seasonal calendar strip, and federal/criminal heat displays. Basic real estate trading was brought forward from the original 0.2 roadmap.

---

# Time Structure

## Turn Structure
The game operates on MONTHLY TURNS.

Each turn represents:
- One calendar month
- Market movement
- Historical events
- Economic updates
- Suspicion calculations

Monthly turns were chosen because they:
- Preserve historical timing importance
- Allow market anticipation
- Reduce excessive micromanagement
- Keep pacing manageable

---

# Primary Player Goal

The player's primary objective is:

> Maximize wealth accumulation over the course of history.

There is intentionally NO HARD CEILING on wealth.

The game should answer:
> "How much wealth could someone realistically accumulate with future knowledge?"

Potential player outcomes:
- Millionaire
- Billionaire
- Trillionaire
- Effective controller of global markets
- Timeline destabilizer

---

# Historical Scope

## Initial Timeline

The current timeline is named **Real World** and is identified on the dashboard as **Real World Timeline**. This names the intended historical setting; current prototype market data remains illustrative rather than historically sourced.

Players will eventually be able to switch to fictional timelines or slightly different versions of history. Timeline switching is a planned feature, not yet implemented. Switching rules and whether player progress carries between timelines remain to be designed.

Preferred starting timeline:
- 1980 -> 2026

Alternative possible timeline:
- 1990 -> 2026

1980 is currently preferred due to:
- Longer compounding opportunities
- Broader historical coverage
- Early tech company investments
- Greater economic event diversity

---

# Core Systems

# 1. Financial Systems

## Current Trading and Settlement Rules

Stocks and properties have separate order desks and queues but share cash. The prototype offers three fictional stocks (Atlas Industries, Pioneer Computing, Union Manufacturing), residential homes, and commercial properties. Trades use whole shares or whole properties; there is no short selling, borrowing, or fractional ownership.

- A submitted order locks its quoted price and settlement date. This is a provisional prototype rule, not realistic exchange execution.
- Buys reserve their full cost immediately. Sells reserve the owned units. Neither money nor ownership transfers until settlement.
- Reserved cash cannot fund another order; reserved units cannot be sold twice. Pending purchase units cannot be sold before ownership transfers.
- Cancelling a pending order releases its reservation without a fee or heat increase.
- Stock buys and sells settle next month. Property buys and sells use the seasonal closing schedule below, based on the month submitted.

| Submission month | Residential closing delay | Commercial closing delay |
| --- | --- | --- |
| December-February | 3 months | 4 months |
| March, September-November | 2 months | 3 months |
| April-August | 1 month | 2 months |

Closing delays are provisional game rules. Initial property quotes are $45,000 for a home and $150,000 for commercial property, so the starting $100 does not immediately buy property.

**Available cash** equals total cash minus pending buy reservations. **Holdings value** uses current illustrative prices. **Net worth** equals total cash (including reserved cash) plus holdings value; pending orders are not counted as extra assets or liabilities. **Total return** compares net worth with the original $100.

On Advance month, the simulation moves forward, reduces federal heat, settles due orders at their locked prices, adds settlement heat, and refreshes valuations, queues, calendar, and historical news. Longer property orders remain queued with updated time remaining.

There are currently no dividends, rental income, operating costs, trading fees, taxes, financing, or transaction failures. Price movements follow deterministic illustrative curves shared with the charts, not historical price data.

## Planned Asset Classes
- Stocks
- Index funds
- Real estate
- Sports betting
- Commodities
- Bonds
- Cryptocurrency (later timeline)
- Startup/private investments
- Options/leverage (later)

---

## Core Financial Concepts
The game should model:
- Compound growth
- Inflation
- Liquidity
- Taxes
- Risk
- Volatility
- Leverage
- Diversification
- Timing

---

# 2. Historical Event System

The world progresses through historical events.

Examples:
- Black Monday
- Dot-com bubble
- Housing crash
- Bitcoin emergence
- COVID crash
- AI boom
- Major sports events
- Wars
- Oil crises

The player uses future knowledge to exploit these events.

## Current Historical News Integration

### Archive Contents and Location

The active archive is **v0.2.0**, stored under `project-bit/project_bit_history_1980_1984_v0.2/project_bit_history_1980_1984_v0.2/`. The earlier v0.1 archive remains on disk but is not loaded by the game.

- `YYYY/YYYY-MM.json`: one runtime file per month, 60 months total.
- `history_1980_1984_master.json`: consolidated archive; the game reads monthly files rather than loading both copies.
- `sources.json`: shared source registry, referenced by record keys.
- `history.schema.json`: monthly JSON structure specification.
- Archive `README.md`: research notes, data conventions, and provenance limitations.

The archive contains **1,080 records: 183 discrete events and 897 monthly context records**. Eighteen records per month does not mean eighteen separate historical happenings. Context can recur across months as an ongoing condition.

### Record Contract

| Field | Meaning / intended use |
| --- | --- |
| `id` | Stable record identity; preserve for future saves and narrative references. |
| `date`, `date_precision` | Historical date, either `YYYY-MM-DD` or month-only `YYYY-MM`; do not invent exact days for context. |
| `known_as_of` | Earliest assumed public availability; current filtering operates at month precision. |
| `record_type` | `event` for a discrete occurrence, `monthly_context` for ongoing conditions or background. |
| `topic_class` | One of the six browsing topics listed below. |
| `headline`, `summary` | Player-facing historical text. |
| `category`, `scope`, `tags` | Subject, geography, and descriptive metadata. |
| `economic_sectors`, `game_relevance` | Interpretive design hooks, not measured asset returns or automatic price instructions. |
| `importance` | Editorial significance from 1 to 5; used to prioritize display. |
| `source_keys` | References into `sources.json` for provenance shown on hover. |

Monthly wrappers also identify `dataset`, `dataset_version`, `year`, `month`, `period`, `event_count`, and `topic_class_targets`. Event records live in the `events` array even when their type is `monthly_context`.

### Display and Reveal Rules

The Real World Timeline news panel reads the v0.2 archive for January 1980 through December 1984. Each month contains 18 records: three each for economics/markets, business/technology, politics/geopolitics, sports, pop culture, and society/science/disasters.

Records explicitly distinguish discrete events from ongoing monthly context. The panel is a **month-end review of the displayed month**, including January 1980 at startup. It shows events before context, prioritizes importance within each type, supports topic filtering, and exposes source references on headline hover. Player activity has its own filter. Later-month event dates or `known_as_of` dates are not revealed. Sports betting will require separate pre-result reveal timing when implemented.

Advancing time replaces the review with the new month's records. Outside archive coverage, the UI displays a coverage notice. Historical news and interpretive sector tags do not currently change the illustrative market prices.

The six topic keys are `economics_markets`, `business_technology`, `politics_geopolitics`, `sports`, `pop_culture`, and `society_science_disasters`. All 18 records are accessible by scrolling in All topics, or three per topic through the selector. Arrival, monthly status, and trade settlement messages are player activity, not historical archive records. The feed retains the displayed month's review, not a browsable log of all past months.

The current review intentionally includes outcomes within the displayed month. Before sports betting is playable, define wagering cutoffs and result publication separately so a player cannot place a bet after reading its result. This remains an open design task.

### Data Quality and Extension

The pack is a research baseline, not an exhaustive or independently verified chronology. Structural checks cover monthly counts, topic counts, source references, and unique IDs; these do not establish historical accuracy. Verify facts and obtain appropriate price/economic data before making a record drive deterministic financial consequences.

Future archive expansions should preserve stable IDs and explicit event/context distinctions. Do not manufacture discrete events to meet the per-topic quota. Runtime loading currently points to the v0.2 folder; a replacement archive needs an explicit path/configuration update and validation. Godot exports must include the JSON files using the non-resource export filter (`*.json`).

---

# 3. Educational Layer

Project BIT is partially educational.

Players should learn:
- When major events occurred
- Why markets moved
- Historical economic trends
- Investment concepts
- Risk management

The game should encourage:
- Historical curiosity
- Financial literacy
- Understanding of compounding

Education should emerge naturally through gameplay.

---

# 4. Suspicion / Detection System

## Overview

One of the game's primary balancing systems is:
> suspicion from authorities and organizations.

The player's future knowledge creates statistically impossible behavior patterns.

If the player becomes too successful too consistently:
- regulators notice
- criminals notice
- intelligence agencies notice
- sportsbooks notice

The player must balance:
- profitability
- visibility
- concealment

---

## Core Design Principle

The player's greatest advantage:
> future knowledge

is also:
> their greatest liability.

---

# Suspicion Categories

## Visibility Window: Two Independent Heat Channels

The Visibility window separates attention into two independent scores, rather than one combined visibility meter:

- **Federal government heat:** combined FBI and IRS interest in the player's financial activity.
- **Criminal organization heat:** interest associated with the future sports betting system.

Both channels have their own meter on a 0-100 scale, and the main dashboard displays both scores. FBI and IRS interest currently share one federal score; they are not separate meters.

### Current Prototype Rules

- Each settled stock or real estate transaction adds **0.5 federal heat plus 1 point per $10,000 of transaction value**, for either buying or selling.
- Federal heat decreases by **1 point at the start of each month**, before that month's settlements add heat. It stays between 0 and 100.
- Queued orders and cancelled orders add no heat. Only completed transactions count.
- Federal status bands: **below 20 = Low profile**, **20 to below 50 = Noticed**, and **50 or above = High profile**.
- Criminal organization heat remains **inactive at zero until sports betting is implemented**. Stock trades, real estate transactions, and wealth alone do not raise it.
- Sports betting heat triggers, thresholds, and decay rules are still to be designed.
- Heat currently provides feedback only. Investigations, restrictions, and penalties are future systems.

The federal formula is provisional game balancing, not a model of actual agency behavior. The future triggers and consequences below are design goals, not implemented mechanics.

## Federal Government Heat: FBI and IRS
Current represented agencies:
- FBI
- IRS

Other regulators, including the SEC, may be considered in future expansions; they are not separate current heat channels.

Potential future triggers beyond the prototype transaction formula:
- impossible investment timing
- abnormal returns
- suspicious tax behavior
- repeated perfect trades

Potential consequences:
- audits
- account freezes
- investigations
- denied trading access

---

## Sports Betting Scrutiny (Future)

If sports betting is implemented:
- perfect prediction becomes dangerous
- betting activity can generate criminal organization heat, with detailed rules to be determined

Examples:
- predicting every Super Bowl
- predicting every upset
- flawless betting streaks

Potential consequences:
- sportsbook bans
- criminal investigations
- organized crime attention

---

## Criminal Organization Heat (Future Sports Betting)

Sports betting activity and conspicuously successful predictions may attract:
- organized crime
- extortion attempts
- manipulation attempts

This channel is tied to sports betting, not general wealth accumulation or stock/property trading. It remains inactive in the current prototype.

Potential consequences:
- coercion
- theft
- forced partnerships

---

## Intelligence Agencies (Long-Term Concept)

This is a possible future expansion, not an additional implemented heat channel. The current Visibility window has only federal government heat and criminal organization heat.

Perfect prediction of:
- geopolitical events
- commodity spikes
- wars
- disasters

may trigger intelligence scrutiny.

Potential consequences:
- surveillance
- interrogation
- asset restrictions

---

# Soft Intervention Philosophy

The game should avoid:
- immediate hard game over states

Instead, rising suspicion creates escalating pressure.

Examples:
- audits
- surveillance
- account freezes
- denied loans
- increased taxes
- media attention
- restrictions on activity

This creates:
- tension
- paranoia
- strategic concealment gameplay

---

# Signal vs Noise Mechanic

Players should NOT be encouraged to behave perfectly.

Optimal gameplay may involve:
- intentionally losing occasionally
- making mediocre investments
- spreading activity across sectors
- masking patterns

The player must avoid appearing omniscient.

---

# Historical Divergence (Future System)

## Purpose
Prevent the game from becoming:
- deterministic
- solved
- one-play-only

---

## Elastic History Concept

History remains recognizable but flexible.

Examples:
- crashes occur earlier/later
- companies rise differently
- technologies emerge at altered speeds
- alternate winners emerge

The player's actions may destabilize the timeline.

---

# Long-Term Design Vision

The game may eventually evolve from:
> wealth accumulation simulator

into:
> historical influence simulator

Late-game systems may include:
- political influence
- media ownership
- technological acceleration
- alternate history shaping
- timeline instability

---

# Visual / UI Direction

## Current Dashboard Layout

- Full-screen 2D financial dashboard: current month/year at top left, net worth at top right, Project BIT and **Real World Timeline** centered.
- A 12-month strip sits below the header, with the year at far left and a diamond over the current month. It advances left to right and resets at January with the new year.
- Northern-hemisphere season colors: winter blue (December-February), spring green (March-May), summer gold (June-August), autumn orange (September-November).
- Financial overview shows available cash, holdings value, and total return. Visibility is its own adjacent panel.
- Middle charts show stocks on the left and residential/commercial property on the right. Both offer 1Y, 3Y, and 5Y ranges plus hover values. Chart values are illustrative indices with January 1975 = 100, not quoted dollar prices.
- Monthly news sits at bottom left; the Advance Month panel contains the combined action queue and turn button.
- F11 toggles fullscreen. Esc closes a focused subwindow or returns the main dashboard to windowed mode. Trading and Visibility windows can be moved and closed independently.

## Dashboard Market Navigation

The Advance Month panel includes a scrollable summary of all pending transactions, sorted by settlement date. Each entry shows the action, asset, quantity, total value, settlement month, and whether it settles next turn or remains pending for additional months. The summary refreshes after submission, cancellation, and month advancement. Stock buys are green, stock sells pink, property buys blue, and property sells orange; text labels also identify every action. A count shows total pending actions and how many settle next turn.

The stock market and real estate chart panels each contain their own **Buy / Sell & Queue** button. The stock panel opens a dedicated stock trading window; the real estate panel opens a separate property trading window. Each window shows its own asset choices, holdings, and pending transaction queue with settlement dates and cancellation controls. Both markets share the player's cash balance and reserve funds against the same available cash total. Visibility has its own dashboard panel beside the financial overview, separate from the Advance month controls. It displays federal and criminal heat scores, with a View details button opening the full Visibility window.

The game does NOT require high-end graphics.

Preferred presentation:
- dashboards
- charts
- spreadsheets
- fake news headlines
- financial terminals
- timeline visualizations
- newspapers/magazines

Visual inspiration:
- Bloomberg terminals
- retro financial software
- documentary interfaces
- strategy game dashboards

---

# Development Philosophy

Project BIT should be developed iteratively.

The goal is:
- prove the simulation is fun first
- expand scope later

Priority order:
1. Core financial loop
2. Historical events
3. Suspicion mechanics
4. Alternate history systems
5. Narrative systems
6. Advanced world simulation

---

# Prototype Roadmap

## Current Limits and Open Decisions

- Runs are currently in memory only: no save/load, persistence, or past-month news browser.
- The target timeline extends to 2026, but loaded historical news currently ends in December 1984. Time can advance beyond that; a coverage notice replaces unavailable historical records.
- Historical stock/property price datasets, real company listings, and corporate actions are not integrated. The Real World label identifies the setting, not a claim that the current financial model reproduces history.
- Sports betting, criminal heat triggers, investigations, and penalties remain unimplemented.
- Fictional/alternate timeline selection, divergence rules, and progress transfer between timelines remain undecided.
- Locked order prices, seasonal closing durations, and the federal heat formula are prototype balancing choices to revisit during playtesting.
- Priority design decisions include pre-result betting timing, historical price sourcing, save format, and whether past news should remain browsable. These are outstanding decisions, not newly approved mechanics.

## Prototype 0.1
Focus:
- stock simulation
- monthly turns
- historical timeline
- spreadsheet UI
- basic suspicion

---

## Prototype 0.2
Add:
- deeper real estate systems (basic buying/selling and seasonal settlement already exist)
- leverage
- taxes
- event chains
- economic indicators

---

## Prototype 0.3
Add:
- alternate history
- AI competitors
- influence systems
- startup investing
- advanced investigations

---

# Core Emotional Targets

The game should create:
- excitement
- greed
- paranoia
- anticipation
- regret
- curiosity
- optimization satisfaction

The player should constantly feel:
> "I know something the world does not."
