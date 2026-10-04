extends Control
## Northern-hemisphere seasons; game time has month precision.

const MONTHS := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
const SEASONS := ["WINTER", "SPRING", "SUMMER", "AUTUMN"]
const COLORS := [Color("79bceb"), Color("70d6a0"), Color("edce78"), Color("df986d")]
var current_month := 0
var current_year := 1980


func _ready() -> void:
	custom_minimum_size = Vector2(600, 74)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_date(month: int, year: int) -> void:
	current_month = month
	current_year = year
	queue_redraw()


func _text(position: Vector2, value: String, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw() -> void:
	var ink := Color("e5edf5")
	_text(Vector2(0, 24), str(current_year), 28, ink)
	_text(Vector2(1, 45), "CALENDAR", 10, Color("8fa4b8"))
	var left := 94.0
	var cell_width := (size.x - left) / 12.0
	for month in range(12):
		var season := 0 if month in [11, 0, 1] else (1 if month < 5 else (2 if month < 8 else 3))
		var color: Color = COLORS[season]
		var x := left + cell_width * month
		var rect := Rect2(x + 2, 19, cell_width - 4, 29)
		draw_rect(rect, Color(color, 0.25 if month == current_month else 0.09))
		draw_rect(Rect2(x + 2, 45, cell_width - 4, 3), color)
		var width := ThemeDB.fallback_font.get_string_size(MONTHS[month], HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		_text(Vector2(x + (cell_width - width) / 2, 38), MONTHS[month], 12, ink if month == current_month else color)
		if month == current_month:
			draw_rect(rect, color, false, 1.0)
			var center := Vector2(x + cell_width / 2, 9)
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -6), center + Vector2(6, 0), center + Vector2(0, 6), center + Vector2(-6, 0)]), ink)
		if month in [0, 2, 5, 8, 11]:
			_text(Vector2(x + 5, 65), SEASONS[season], 9, color)
