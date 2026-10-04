# Project BIT dashboard prototype

Open `project.godot` in Godot 4.6 and press **F6** with `dashboard.tscn` open, or **F5** to run the project.

- Starts fullscreen in January 1980 with $100.
- Top left: simulation month and year. Top right: current wealth.
- Beneath the header: a 12-month calendar strip with the year at left and a diamond marking the current month. Northern-hemisphere seasons use blue for winter, green for spring, gold for summer, and orange for autumn. The marker resets to January as the year advances.
- Bottom left: scrollable monthly review from the v0.2 historical archive, with events before monthly context and higher importance first within each type. Choose all topics, any of six topics, or player activity; hover headlines for source references.
- **Advance month** progresses the calendar, settles due orders, and loads the displayed month's historical review.
- Its taller panel summarizes pending actions, ordered by settlement date, with next-turn counts and scrolling for long queues. Stock buys are green, stock sells pink, property buys blue, and property sells orange. Every entry also has a text action label, quantity, value, and closing date.
- Middle left: stock chart with broad market, technology, and industrials selectors.
- Middle right: real estate chart comparing homes and commercial property, with individual series views.
- Both charts offer 1Y, 3Y, and 5Y ranges and hover values. They advance with the game calendar and use illustrative indices (January 1975 = 100), not historical prices.
- **F11** toggles fullscreen; **Esc** switches to windowed mode.

Use **Buy / Sell & Queue** inside the stock chart or real estate chart to open that market's trading window. Each window contains only its own assets, holdings, and pending queue; cash and reservations are shared across both markets. **Visibility / Heat** has its own panel beside the financial overview, showing federal and criminal heat; **View details** opens its window. All are movable in-game subwindows; close with their X or Esc.

The trading windows support whole-share trades in three fictional stocks and whole-property purchases/sales of homes and commercial properties. Stocks follow the corresponding chart indices. Prices lock when queued. Buy orders reserve cash; sell orders reserve holdings. Cancel pending orders to release reservations. No cash or ownership transfers until settlement. Net worth includes reserved cash and owned assets at current prices.

Stocks settle next month. Residential property takes 3 months in December-February, 1 month in April-August, and 2 months otherwise. Commercial property takes an additional month. These are prototype game rules, with the closing date fixed at submission. The starting $100 can buy stocks; property requires more capital (initial quotes: $45,000 home / $150,000 commercial). No borrowing or fractional property ownership is implemented.

Visibility has two independent channels. **Federal government heat** represents combined FBI and IRS interest: it adds 0.5 points plus 1 per $10,000 for each settled stock/property transaction and decays by 1 at the start of each month, bounded to 0-100. **Criminal organization heat** is reserved for future sports betting and remains inactive at zero; stock/property trades never raise it. Neither channel has penalties yet.

The interface is built by `dashboard.gd`; `simulation.gd` owns transaction state and shared illustrative market curves. `history_archive.gd` reads the existing v0.2 monthly JSON files directly (January 1980-December 1984, 18 records/month). The displayed month is a retrospective through month-end: `known_as_of` and event dates prevent later-month records appearing early. Future sports betting will need its own pre-result reveal timing. Missing coverage shows an explicit notice. History metadata does not change market prices. For Godot exports, include `*.json` in the non-resource export filter so the archive is packaged. Save/load is not implemented. Run checks with Godot: `--headless --path project-bit --script res://verify_simulation.gd`.
