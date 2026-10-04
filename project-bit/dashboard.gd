extends Control
## Dashboard and trading UI for the illustrative monthly simulation.

const MONTHS := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const BACKGROUND := Color("0b1119")
const PANEL := Color("121d29")
const BORDER := Color("253647")
const INK := Color("e5edf5")
const MUTED := Color("8fa4b8")
const ACCENT := Color("70e0bb")
const MarketChart := preload("res://market_chart.gd")

var month := 0
var year := 1980
var wealth := 100.0
var date_label: Label
var wealth_label: Label
var news_feed: VBoxContainer
var news_scroll: ScrollContainer
var news_count: Label
var charts: Array[Control] = []
var simulation := preload("res://simulation.gd").new()
var metric_labels: Array[Label] = []
var stock_window: Window
var property_window: Window
var visibility_window: Window
var visibility_content: VBoxContainer
var visibility_label: Label
var visibility_meter: ProgressBar
var criminal_heat_meter: ProgressBar
var criminal_heat_label: Label
var calendar_strip: Control
var turn_queue: VBoxContainer
var turn_queue_count: Label
var history_archive := preload("res://history_archive.gd").new()
var history_records: Array[Dictionary] = []
var activity_records: Array[Dictionary] = []
var news_filter: OptionButton


func _ready() -> void:
	_build_dashboard()
	_build_subwindows()
	_refresh_header()
	_add_news("ARRIVAL", "A new life. A familiar history.", "You arrive in January 1980 with $100 and knowledge of what comes next. Your first chapter begins here.")
	_load_history()


func _panel_style(color: Color = PANEL) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style


func _label(value: String, size: int = 16, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _box(parent: Node, vertical: bool = true, spacing: int = 12) -> BoxContainer:
	var box: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	parent.add_child(box)
	return box


func _card(parent: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	parent.add_child(panel)
	return panel


func _build_dashboard() -> void:
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var main := _box(margin, true, 12)
	var header := _box(main, false, 24)
	var calendar := _box(header, true, 4)
	calendar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	calendar.add_child(_label("SIMULATION DATE", 13, MUTED))
	date_label = _label("", 32)
	calendar.add_child(date_label)
	var brand := _box(header, true, 4)
	var title := _label("PROJECT / BIT", 22, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_child(title)
	var timeline_label := _label("Real World Timeline", 14, MUTED)
	timeline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timeline_label.tooltip_text = "Current timeline: Real World. Fictional and alternate historical timelines are planned. Market data is illustrative in this prototype."
	brand.add_child(timeline_label)
	var balance := _box(header, true, 4)
	balance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var balance_title := _label("CURRENT WEALTH", 13, MUTED)
	balance_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	balance.add_child(balance_title)
	wealth_label = _label("", 32, ACCENT)
	wealth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	balance.add_child(wealth_label)
	calendar_strip = preload("res://calendar_strip.gd").new()
	main.add_child(calendar_strip)
	var overview_row := _box(main, false, 24)
	var overview := _card(overview_row)
	overview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overview.size_flags_stretch_ratio = 2.2
	var overview_content := _box(overview, true, 14)
	var metrics := _box(overview_content, false, 32)
	for entry in [["AVAILABLE CASH", "$100.00"], ["HOLDINGS VALUE", "$0.00"], ["TOTAL RETURN", "0.00%"]]:
		var metric := _box(metrics, true, 8)
		metric.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		metric.add_child(_label(entry[0], 12, MUTED))
		var value_label := _label(entry[1], 26)
		metric.add_child(value_label)
		metric_labels.append(value_label)
	var visibility_panel := _card(overview_row)
	visibility_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var visibility_summary := _box(visibility_panel, true, 8)
	var visibility_heading := _box(visibility_summary, false, 12)
	var visibility_title := _label("VISIBILITY / HEAT", 12, MUTED)
	visibility_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visibility_heading.add_child(visibility_title)
	var visibility_button := Button.new()
	visibility_button.text = "View details"
	visibility_button.add_theme_font_size_override("font_size", 12)
	visibility_heading.add_child(visibility_button)
	visibility_button.pressed.connect(func() -> void: visibility_window.popup_centered())
	var heat_summary := _label("", 20)
	visibility_summary.add_child(heat_summary)
	metric_labels.append(heat_summary)
	var workspace := _box(main, false, 24)
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_chart(workspace, false)
	_build_chart(workspace, true)
	var bottom := _box(main, false, 24)
	bottom.custom_minimum_size.y = 280
	var news_panel := _card(bottom)
	news_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_panel.size_flags_stretch_ratio = 1.6
	var news_content := _box(news_panel, true, 14)
	var news_header := _box(news_content, false)
	var news_title := _label("MONTH IN REVIEW", 13, ACCENT)
	news_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_header.add_child(news_title)
	news_count = _label("", 12, MUTED)
	news_header.add_child(news_count)
	news_filter = OptionButton.new()
	for caption in ["All topics", "Economics / markets", "Business / technology", "Politics / geopolitics", "Sports", "Pop culture", "Society / science / disasters", "Player activity"]:
		news_filter.add_item(caption)
	news_filter.add_theme_font_size_override("font_size", 12)
	news_filter.tooltip_text = "Monthly review: historical events and context known by the end of the displayed month. Hover over a headline for sources."
	news_header.add_child(news_filter)
	news_filter.item_selected.connect(func(_index: int) -> void: _render_news())
	news_scroll = ScrollContainer.new()
	news_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	news_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	news_content.add_child(news_scroll)
	news_feed = VBoxContainer.new()
	news_feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_feed.add_theme_constant_override("separation", 18)
	news_scroll.add_child(news_feed)
	var turn_panel := _card(bottom)
	turn_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var turn_content := _box(turn_panel, true, 10)
	turn_content.add_child(_label("ADVANCE MONTH / QUEUED ACTIONS", 13, ACCENT))
	turn_queue_count = _label("", 12, MUTED)
	turn_content.add_child(turn_queue_count)
	var queue_scroll := ScrollContainer.new()
	queue_scroll.custom_minimum_size.y = 80
	queue_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	queue_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	turn_content.add_child(queue_scroll)
	turn_queue = VBoxContainer.new()
	turn_queue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	turn_queue.add_theme_constant_override("separation", 10)
	queue_scroll.add_child(turn_queue)
	var advance := Button.new()
	advance.text = "Advance month  →"
	advance.custom_minimum_size.y = 54
	advance.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	advance.add_theme_font_size_override("font_size", 18)
	advance.add_theme_color_override("font_color", BACKGROUND)
	advance.add_theme_color_override("font_hover_color", BACKGROUND)
	advance.add_theme_color_override("font_pressed_color", BACKGROUND)
	advance.add_theme_stylebox_override("normal", _panel_style(ACCENT))
	advance.add_theme_stylebox_override("hover", _panel_style(Color("95edcf")))
	advance.add_theme_stylebox_override("pressed", _panel_style(Color("4aba97")))
	advance.pressed.connect(_advance_month)
	turn_content.add_child(advance)
	var footer := _label("PROTOTYPE 0.1    /    HISTORICAL FINANCE SIMULATION                                         F11  FULLSCREEN    ·    ESC  WINDOWED", 11, MUTED)
	main.add_child(footer)


func _refresh_header() -> void:
	wealth = simulation.net_worth()
	date_label.text = "%s %d" % [MONTHS[month], year]
	calendar_strip.set_date(month, year)
	wealth_label.text = "$%.2f" % wealth
	metric_labels[0].text = "$%.2f" % simulation.available_cash()
	metric_labels[1].text = "$%.2f" % simulation.invested_value()
	metric_labels[2].text = "%+.2f%%" % ((wealth / 100.0 - 1.0) * 100.0)
	metric_labels[3].text = "Federal %.1f  |  Criminal %.1f" % [simulation.federal_heat, simulation.criminal_heat]
	metric_labels[3].tooltip_text = "Federal heat (FBI / IRS) | Criminal organization heat (future sports betting)"
	_refresh_portfolio()
	_refresh_turn_queue()
	for chart in charts:
		chart.set_month((year - 1980) * 12 + month)


func _refresh_turn_queue() -> void:
	for child in turn_queue.get_children():
		turn_queue.remove_child(child)
		child.queue_free()
	var ordered: Array = simulation.orders.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.due < b.due if a.due != b.due else a.id < b.id)
	var due_next := 0
	for order in ordered:
		if order.due <= simulation.elapsed + 1:
			due_next += 1
		var property_order: bool = order.asset >= 3
		var color := Color("70e0bb") if order.buy else Color("ed9cb8")
		if property_order:
			color = Color("82bafa") if order.buy else Color("eab675")
		var action := "%s %s" % ["BUY" if order.buy else "SELL", "REAL ESTATE" if property_order else "STOCK"]
		var months_left: int = order.due - simulation.elapsed
		var timing := "NEXT TURN" if months_left == 1 else "%d MONTHS LEFT" % months_left
		var entry := _box(turn_queue, true, 3)
		entry.add_child(_wrapped("%s / %s" % [action, timing], color))
		entry.add_child(_wrapped("#%d: %d x %s | $%.2f\nSettles %s" % [order.id, order.quantity, simulation.ASSETS[order.asset], order.total, _month_text(order.due)], INK))
	turn_queue_count.text = "%d pending / %d settle next turn" % [ordered.size(), due_next]
	if ordered.is_empty():
		turn_queue.add_child(_wrapped("No queued actions. Open Buy / Sell & Queue in either chart to place an order."))


func _build_chart(parent: Node, property_chart: bool) -> void:
	var card := _card(parent)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := _box(card, true, 8)
	var chart_header := _box(content, false, 8)
	var heading := _label("REAL ESTATE VALUES" if property_chart else "STOCK MARKET", 15, ACCENT)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chart_header.add_child(heading)
	var trade_button := Button.new()
	trade_button.text = "Buy / Sell & Queue"
	trade_button.add_theme_font_size_override("font_size", 12)
	chart_header.add_child(trade_button)
	trade_button.pressed.connect(func() -> void:
		var desk := property_window if property_chart else stock_window
		desk.refresh()
		desk.popup_centered())
	var controls := _box(content, false, 10)
	var series := OptionButton.new()
	series.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for option in (["Homes + commercial", "Homes", "Commercial"] if property_chart else ["Broad market", "Technology", "Industrials"]):
		series.add_item(option)
	controls.add_child(series)
	var period := OptionButton.new()
	for option in ["1Y", "3Y", "5Y"]:
		period.add_item(option)
	controls.add_child(period)
	var chart := MarketChart.new()
	chart.property_chart = property_chart
	chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(chart)
	charts.append(chart)
	series.item_selected.connect(chart.set_series)
	period.item_selected.connect(func(index: int) -> void: chart.set_period([12, 36, 60][index]))
	content.add_child(_label("ILLUSTRATIVE DATA / INDEX: JAN 1975 = 100", 10, MUTED))


func _advance_month() -> void:
	var reports := simulation.advance()
	month += 1
	if month == 12:
		month = 0
		year += 1
	_refresh_header()
	activity_records.clear()
	_load_history()
	_add_news("MONTHLY UPDATE", "%s begins" % date_label.text, "Net worth: $%.2f. %d orders pending." % [wealth, simulation.orders.size()])
	for report in reports:
		_add_news("SETTLEMENT", "Transaction completed", report)


func _add_news(category: String, headline: String, body: String) -> void:
	activity_records.push_front({"category": category, "headline": headline, "summary": body})
	_render_news()


func _load_history() -> void:
	history_records = history_archive.load_month(year, month + 1)
	_render_news()


func _render_news() -> void:
	for child in news_feed.get_children():
		news_feed.remove_child(child)
		child.queue_free()
	var shown := 0
	for record in history_records:
		if news_filter.selected == 7:
			continue
		if news_filter.selected > 0 and record.topic_class != history_archive.TOPICS[news_filter.selected - 1]:
			continue
		var kind := "EVENT" if record.record_type == "event" else "MONTHLY CONTEXT"
		_news_item("%s / %s / %s" % [record.date, kind, str(record.topic_class).replace("_", " ").to_upper()], record.headline, record.summary, history_archive.source_text(record))
		shown += 1
	if news_filter.selected != 7 and shown == 0:
		_news_item("ARCHIVE", "No historical records", history_archive.status if not history_archive.status.is_empty() else "No records in this topic for the displayed month.")
	if news_filter.selected in [0, 7]:
		for record in activity_records:
			_news_item("PLAYER / " + record.category, record.headline, record.summary)
	news_count.text = "%d / %d RECORDS" % [shown, history_records.size()]
	news_count.tooltip_text = "Historical records shown / available this month. Player activity is listed separately below."
	news_scroll.set_deferred("scroll_vertical", 0)


func _news_item(category: String, headline: String, body: String, sources: String = "") -> void:
	var item := VBoxContainer.new()
	item.add_theme_constant_override("separation", 6)
	news_feed.add_child(item)
	var metadata := _label(category, 11, ACCENT)
	metadata.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(metadata)
	var heading := _label(headline, 18)
	heading.tooltip_text = sources
	heading.mouse_filter = Control.MOUSE_FILTER_PASS
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(heading)
	var description := _label(body, 14, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(description)


func _make_window(caption: String, dimensions: Vector2i) -> Window:
	get_viewport().gui_embed_subwindows = true
	var window := Window.new()
	window.title = caption
	window.size = dimensions
	window.min_size = Vector2i(600, 400)
	window.visible = false
	add_child(window)
	window.close_requested.connect(window.hide)
	window.window_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			window.hide())
	return window


func _window_content(window: Window) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _panel_style())
	window.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)
	return content


func _wrapped(value: String, color: Color = MUTED) -> Label:
	var label := _label(value, 14, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _build_subwindows() -> void:
	get_viewport().gui_embed_subwindows = true
	stock_window = preload("res://trade_desk.gd").new()
	stock_window.dashboard = self
	stock_window.property_market = false
	add_child(stock_window)
	property_window = preload("res://trade_desk.gd").new()
	property_window.dashboard = self
	property_window.property_market = true
	add_child(property_window)
	visibility_window = _make_window("Visibility", Vector2i(700, 610))
	visibility_content = _window_content(visibility_window)
	visibility_content.add_child(_label("VISIBILITY / HEAT", 22, ACCENT))
	visibility_content.add_child(_label("FEDERAL GOVERNMENT / FBI & IRS", 16, ACCENT))
	visibility_meter = ProgressBar.new()
	visibility_meter.custom_minimum_size.y = 28
	visibility_content.add_child(visibility_meter)
	visibility_label = _wrapped("", INK)
	visibility_content.add_child(visibility_label)
	visibility_content.add_child(_wrapped("Tracks FBI and IRS interest in your financial activity as a combined federal heat score."))
	visibility_content.add_child(_wrapped("Prototype rule: each settled stock or property transaction adds 0.5 federal heat plus 1 point per $10,000 traded. Federal heat falls by 1 at the start of each month. Queued and cancelled orders add no heat."))
	visibility_content.add_child(HSeparator.new())
	visibility_content.add_child(_label("CRIMINAL ORGANIZATIONS / SPORTS BETTING", 16, Color("eab675")))
	criminal_heat_meter = ProgressBar.new()
	criminal_heat_meter.custom_minimum_size.y = 28
	visibility_content.add_child(criminal_heat_meter)
	criminal_heat_label = _wrapped("", INK)
	visibility_content.add_child(criminal_heat_label)
	visibility_content.add_child(_wrapped("This heat channel will track criminal organization interest from sports betting. It remains inactive until betting is implemented. Stock and property transactions do not raise criminal heat."))
	visibility_content.add_child(_wrapped("Federal levels: below 20 = Low profile / 20-49 = Noticed / 50+ = High profile.\nInvestigations and penalties are not implemented yet."))


func _month_text(elapsed: int) -> String:
	return "%s %d" % [MONTHS[posmod(elapsed, 12)], 1980 + floori(float(elapsed) / 12.0)]


func _refresh_portfolio() -> void:
	if is_instance_valid(stock_window):
		stock_window.refresh()
		property_window.refresh()
	visibility_meter.value = simulation.federal_heat
	var status := "Low profile" if simulation.federal_heat < 20 else ("Noticed" if simulation.federal_heat < 50 else "High profile")
	visibility_label.text = "%s | Federal heat: %.1f / 100" % [status, simulation.federal_heat]
	criminal_heat_meter.value = simulation.criminal_heat
	criminal_heat_label.text = "Inactive | Criminal heat: %.1f / 100 | Sports betting coming later" % simulation.criminal_heat


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif event.keycode == KEY_ESCAPE:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
