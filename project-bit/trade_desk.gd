extends Window
## Separate market desks sharing the player's cash and settlement model.

var dashboard: Control
var property_market := false
var asset_picker: OptionButton
var side_picker: OptionButton
var quantity: SpinBox
var quote: Label
var feedback: Label
var holdings: Label
var pending: VBoxContainer
var asset_ids: Array[int] = []


func _ready() -> void:
	title = "Real Estate / Properties & Closing Queue" if property_market else "Stocks / Trading & Order Queue"
	size = Vector2i(850, 640)
	min_size = Vector2i(650, 400)
	visible = false
	close_requested.connect(hide)
	window_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			hide())
	if property_market:
		asset_ids.assign([3, 4])
	else:
		asset_ids.assign([0, 1, 2])
	var content: VBoxContainer = dashboard._window_content(self)
	content.add_child(dashboard._label("REAL ESTATE / PROPERTY DESK" if property_market else "STOCKS / TRADING DESK", 22, dashboard.ACCENT))
	content.add_child(dashboard._wrapped("Illustrative prices. Whole properties; seasonal closings take 1-4 months." if property_market else "Fictional stocks. Whole shares; orders settle next month."))
	content.add_child(dashboard._wrapped("Quotes lock at submission. Buys reserve shared cash; sells reserve holdings until settlement or cancellation."))
	var row: BoxContainer = dashboard._box(content, false)
	asset_picker = OptionButton.new()
	asset_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for asset in asset_ids:
		asset_picker.add_item(dashboard.simulation.ASSETS[asset], asset)
	row.add_child(asset_picker)
	side_picker = OptionButton.new()
	side_picker.add_item("Buy")
	side_picker.add_item("Sell")
	row.add_child(side_picker)
	row.add_child(dashboard._label("Quantity", 14))
	quantity = SpinBox.new()
	quantity.min_value = 1
	quantity.max_value = 100000
	quantity.value = 1
	row.add_child(quantity)
	quote = dashboard._wrapped("", dashboard.INK)
	content.add_child(quote)
	asset_picker.item_selected.connect(func(_index: int) -> void: refresh_quote())
	quantity.value_changed.connect(func(_value: float) -> void: refresh_quote())
	var submit := Button.new()
	submit.text = "Queue property transaction" if property_market else "Queue stock order"
	submit.custom_minimum_size.y = 40
	submit.pressed.connect(submit_order)
	content.add_child(submit)
	feedback = dashboard._wrapped("Orders resolve when you advance the month.", dashboard.ACCENT)
	content.add_child(feedback)
	content.add_child(dashboard._label("PROPERTIES & SHARED CASH" if property_market else "STOCK HOLDINGS & SHARED CASH", 16, dashboard.ACCENT))
	holdings = dashboard._wrapped("", dashboard.INK)
	content.add_child(holdings)
	content.add_child(dashboard._label("PROPERTY CLOSING QUEUE" if property_market else "STOCK ORDER QUEUE", 16, dashboard.ACCENT))
	pending = VBoxContainer.new()
	pending.add_theme_constant_override("separation", 10)
	content.add_child(pending)
	refresh()


func refresh_quote() -> void:
	var asset := asset_picker.get_selected_id()
	var model = dashboard.simulation
	quote.text = "$%.2f each | Total $%.2f\nSettles %s (%d months)" % [model.price(asset), model.price(asset) * quantity.value, dashboard._month_text(model.elapsed + model.delay(asset)), model.delay(asset)]


func submit_order() -> void:
	quantity.apply()
	var error: String = dashboard.simulation.queue_order(asset_picker.get_selected_id(), side_picker.selected == 0, int(quantity.value))
	feedback.text = error if not error.is_empty() else "Queued. Reservation held until settlement or cancellation."
	dashboard._refresh_header()


func cancel_order(id: int) -> void:
	dashboard.simulation.cancel_order(id)
	feedback.text = "Order #%d cancelled. Reservation released." % id
	dashboard._refresh_header()


func refresh() -> void:
	if not is_instance_valid(holdings):
		return
	refresh_quote()
	var model = dashboard.simulation
	holdings.text = "Shared cash $%.2f | Reserved across both markets $%.2f | Available $%.2f\n" % [model.cash, model.reserved_cash(), model.available_cash()]
	for asset in asset_ids:
		holdings.text += "\n%s: %d owned / %d available to sell | Value $%.2f" % [model.ASSETS[asset], model.holdings[asset], model.available_units(asset), model.holdings[asset] * model.price(asset)]
	for child in pending.get_children():
		pending.remove_child(child)
		child.queue_free()
	for order in model.orders:
		if order.asset not in asset_ids:
			continue
		var row: BoxContainer = dashboard._box(pending, false)
		var label: Label = dashboard._wrapped("#%d %s %d x %s | $%.2f\nCloses %s (%d months remaining)" % [order.id, "BUY" if order.buy else "SELL", order.quantity, model.ASSETS[order.asset], order.total, dashboard._month_text(order.due), order.due - model.elapsed], dashboard.INK)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var cancel := Button.new()
		cancel.text = "Cancel"
		cancel.pressed.connect(cancel_order.bind(int(order.id)))
		row.add_child(cancel)
	if pending.get_child_count() == 0:
		pending.add_child(dashboard._label("No pending property closings." if property_market else "No pending stock orders.", 14, dashboard.MUTED))
