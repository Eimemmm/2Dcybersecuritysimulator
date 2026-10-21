extends Control
## Matrix rain: เลข 0/1 ไหลลงมาเป็นคอลัมน์ (Godot 4.x)
## วิธีใช้: แปะสคริปต์นี้กับ Control (ชื่อ MatrixRain) แล้วตั้ง Mouse Filter = Ignore

@export var font: Font                      # ลากฟอนต์พิกเซลมาใส่ (ไม่ใส่ก็ใช้ฟอนต์เริ่มต้น)
@export var font_size := 18
@export var column_spacing := 44.0          # ระยะห่างระหว่างคอลัมน์
@export var char_spacing := 20.0            # ระยะห่างระหว่างตัวเลขในคอลัมน์
@export var min_speed := 140.0              # ความเร็วต่ำสุด (px/วินาที)
@export var max_speed := 220.0
@export var min_length := 10               # ความยาวหางต่ำสุด (จำนวนตัวเลข)
@export var max_length := 20
@export var rain_color := Color("00FFCC")   # สีเขียวฟ้าแบบในวิดีโอ
@export var flip_interval := 0.1            # สุ่มเปลี่ยนเลขทุกกี่วินาที

class Stream:
	var x: float
	var head_y: float            # ตำแหน่งแกน y ของตัวเลขหัว (ล่างสุด)
	var speed: float
	var chars: Array[String] = []

var streams: Array[Stream] = []
var _flip_timer := 0.0


func _ready() -> void:
	if font == null:
		font = ThemeDB.fallback_font
	resized.connect(_build_streams)
	_build_streams()


func _build_streams() -> void:
	streams.clear()
	var count := int(size.x / column_spacing)
	for i in count:
		var s := Stream.new()
		s.x = i * column_spacing + column_spacing * 0.5
		_reset_stream(s, true)
		streams.append(s)


func _reset_stream(s: Stream, scatter: bool = false) -> void:
	var length := randi_range(min_length, max_length)
	s.speed = randf_range(min_speed, max_speed)
	s.chars.clear()
	for i in length:
		s.chars.append(_rand_char())
	if scatter:
		# ตอนเริ่มเกม กระจายให้ทั่วจอ ไม่ให้ตกพร้อมกันหมด
		s.head_y = randf_range(0.0, size.y + length * char_spacing)
	else:
		# ตอนวนใหม่ เริ่มเหนือขอบบนแบบสุ่ม จะได้ไม่ตกเป็นจังหวะเดียวกัน
		s.head_y = -randf_range(0.0, size.y * 0.5)


func _rand_char() -> String:
	return "1" if randf() < 0.5 else "0"


func _process(delta: float) -> void:
	for s in streams:
		s.head_y += s.speed * delta
		var tail_y := s.head_y - s.chars.size() * char_spacing
		if tail_y > size.y:
			_reset_stream(s)

	_flip_timer += delta
	if _flip_timer >= flip_interval:
		_flip_timer = 0.0
		for s in streams:
			s.chars[randi() % s.chars.size()] = _rand_char()

	queue_redraw()


func _draw() -> void:
	for s in streams:
		var n := s.chars.size()
		for i in n:                              # i = 0 คือตัวหัว (ล่างสุด)
			var py := s.head_y - i * char_spacing
			if py < 0.0 or py > size.y + font_size:
				continue
			var c := rain_color
			c.a = 1.0 - float(i) / n             # หางค่อยๆ จางขึ้นไปข้างบน
			if i == 0:
				c = c.lightened(0.6)             # ตัวหัวสว่างกว่า
			draw_string(font, Vector2(s.x, py), s.chars[i],
					HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, c)
