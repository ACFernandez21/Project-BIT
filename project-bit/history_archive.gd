extends RefCounted
## Monthly retrospective: only records public by the displayed month's end.

const ROOT := "res://project_bit_history_1980_1984_v0.2/project_bit_history_1980_1984_v0.2/"
const TOPICS := ["economics_markets", "business_technology", "politics_geopolitics", "sports", "pop_culture", "society_science_disasters"]
var status := ""
var sources: Dictionary = {}


func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "sources.json"))
	if parsed is Dictionary:
		sources = parsed


func load_month(year: int, month: int) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var period := "%04d-%02d" % [year, month]
	var path := ROOT + "%04d/%s.json" % [year, period]
	status = ""
	if not FileAccess.file_exists(path):
		status = "No historical coverage for %s. Archive covers January 1980 through December 1984." % period
		return records
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		status = "Historical archive could not be read for %s." % period
		return records
	var data = json.data
	if not data is Dictionary or data.get("period", "") != period or not data.get("events") is Array:
		status = "Historical archive has an invalid month record for %s." % period
		return records
	var seen := {}
	for record in data.events:
		if not record is Dictionary:
			continue
		if not record.has_all(["id", "headline", "summary", "date", "known_as_of", "record_type", "topic_class"]):
			continue
		if str(record.known_as_of).substr(0, 7) > period or str(record.date).substr(0, 7) > period or seen.has(record.id):
			continue
		seen[record.id] = true
		records.append(record)
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.record_type != b.record_type:
			return a.record_type == "event"
		return int(a.get("importance", 0)) > int(b.get("importance", 0)))
	return records


func source_text(record: Dictionary) -> String:
	var lines: PackedStringArray = []
	for key in record.get("source_keys", []):
		if sources.has(key):
			lines.append("%s\n%s" % [sources[key].get("name", key), sources[key].get("url", "")])
	return "\n\n".join(lines)
