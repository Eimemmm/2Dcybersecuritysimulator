extends Label

@export var use_real_time := true        # ติ๊ก = ใช้เวลาจริงของเครื่อง
@export var fake_start := "09:12"        # ใช้เมื่อปิด use_real_time (รูปแบบ HH:MM 24 ชม.)
@export var fake_date := "25/4/2026"     # วันที่ที่แสดงเมื่อใช้เวลาปลอม
@export var show_date := true

var _fake_seconds := 0.0   # วินาทีนับจากเที่ยงคืน


func _ready() -> void:
	var parts := fake_start.split(":")
	_fake_seconds = int(parts[0]) * 3600 + int(parts[1]) * 60
	text = _build_text()


func _process(delta: float) -> void:
	if not use_real_time:
		_fake_seconds += delta
	var new_text := _build_text()
	if new_text != text:   # อัปเดตเมื่อข้อความเปลี่ยนเท่านั้น
		text = new_text


func _build_text() -> String:
	var hour: int
	var minute: int
	var date_str: String
	if use_real_time:
		var now := Time.get_datetime_dict_from_system()
		hour = now["hour"]
		minute = now["minute"]
		date_str = "%d / %d / %d" % [now["day"], now["month"], now["year"]]
	else:
		var total := int(_fake_seconds) % 86400
		hour = floori(total / 3600.0)
		minute = floori((total % 3600) / 60.0)
		date_str = fake_date

	var suffix := "AM" if hour < 12 else "PM"
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12

	var result := "%d:%02d %s" % [hour12, minute, suffix]
	if show_date:
		result += "\n" + date_str
	return result
