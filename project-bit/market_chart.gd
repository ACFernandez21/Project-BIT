extends Control
## Deterministic illustrative indices, not historical prices or investment returns.

const COLORS := [Color("70e0bb"), Color("eab675")]
const MUTED := Color("8fa4b8")
const MONTHS := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
var property_chart := false
var selected_series := 0
var period := 12
var current_month := 0
var hover_position := Vector2(-1, -1)


func _ready() -> void:
	custom_minimum_size = Vector2(260, 140)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)
	mouse_exited.connect(func() -> void:
		hover_position = Vector2(-1, -1)
		queue_redraw())


func set_month(value: int) -> void:
	current_month = value
	queue_redraw()


func set_series(value: int) -> void:
	selected_series = value
	queue_redraw()


func set_period(value: int) -> void:
	period = value
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hover_position = event.position
		queue_redraw()


func _value(t: int, series: int) -> float:
	return preload("res://simulation.gd").index_value(t, series, property_chart)


func _date(t: int) -> String:
	return "%s %d" % [MONTHS[posmod(t, 12)], 1980 + floori(float(t) / 12.0)]


func _text(at: Vector2, value: String, color: Color = MUTED, font_size: int = 11) -> void:
	draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw() -> void:
	var plot := Rect2(48, 38, maxf(1, size.x - 62), maxf(1, size.y - 66))
	var series_ids: Array = [selected_series]
	if property_chart:
		series_ids = [0, 1] if selected_series == 0 else [selected_series - 1]
	var start := current_month - period
	var minimum := INF
	var maximum := -INF
	for series in series_ids:
		for t in range(start, current_month + 1):
			var value := _value(t, series)
			minimum = minf(minimum, value)
			maximum = maxf(maximum, value)
	var padding := maxf(2.0, (maximum - minimum) * 0.15)
	minimum -= padding
	maximum += padding
	for tick in range(5):
		var fraction := float(tick) / 4.0
		var y := plot.position.y + plot.size.y * fraction
		draw_line(Vector2(plot.position.x, y), Vector2(plot.end.x, y), Color("253647"))
		_text(Vector2(0, y + 4), "%.1f" % lerpf(maximum, minimum, fraction))
	for tick in range(3):
		var x := plot.position.x + plot.size.x * float(tick) / 2.0
		draw_line(Vector2(x, plot.position.y), Vector2(x, plot.end.y), Color("1d2b3a"))
		_text(Vector2(clampf(x - 25, 0, size.x - 60), plot.end.y + 19), _date(start + roundi(period * float(tick) / 2.0)))
	var hovering := plot.has_point(hover_position)
	var sample := roundi(clampf((hover_position.x - plot.position.x) / plot.size.x, 0, 1) * period) if hovering else period
	for index in range(series_ids.size()):
		var series: int = series_ids[index]
		var color: Color = COLORS[series] if property_chart else COLORS[0]
		var points := PackedVector2Array()
		for offset in range(period + 1):
			var value := _value(start + offset, series)
			points.append(Vector2(plot.position.x + plot.size.x * float(offset) / period, plot.end.y - (value - minimum) / (maximum - minimum) * plot.size.y))
		draw_polyline(points, color, 2.0, true)
		draw_circle(points[sample], 4.0, color)
		var name: String = ["Homes", "Commercial"][series] if property_chart else ["Broad market", "Technology", "Industrials"][series]
		_text(Vector2(index * size.x * 0.5, 15), "%s  %.1f" % [name, _value(start + sample, series)], color, 12)
	if hovering:
		var x := plot.position.x + plot.size.x * float(sample) / period
		draw_line(Vector2(x, plot.position.y), Vector2(x, plot.end.y), Color("a1b3c580"))
		_text(Vector2(0, 31), _date(start + sample), Color("e5edf5"))
