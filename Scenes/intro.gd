extends Control

@export_file("*.tscn") var next_scene_path := ""
@export var chars_per_second := 30.0   # ความเร็วพิมพ์ ยิ่งมากยิ่งเร็ว
@export var image_fade_time := 0.8     # เวลาเฟดของรูป (วินาที)
@export var pause_after_line := 0.9    # หยุดรอหลังจบแต่ละบรรทัด

@onready var images: Array[TextureRect] = [
	$ColorRect/HBoxContainer/ImageHolder/TextureRect,
	$ColorRect/HBoxContainer/ImageHolder/TextureRect2,
	$ColorRect/HBoxContainer/ImageHolder/TextureRect3,
]
@onready var text_label: RichTextLabel = $ColorRect/RichTextLabel

@onready var type_sound: AudioStreamPlayer2D = $Typesound
	
# แต่ละก้าว: image = รูปที่ขึ้น (-1 = ไม่มีรูปใหม่), line = บรรทัดที่พิมพ์ (นับจาก 0)
const STEPS := [
	{"image": 0, "line": 0},
	{"image": 1, "line": 1},
	{"image": -1, "line": 2},
	{"image": 2, "line": 3},
]

var _line_starts: Array[int] = []
var _line_ends: Array[int] = []
var _tween: Tween


func _ready() -> void:
	for img in images:
		img.modulate.a = 0.0   # ใช้ modulate ไม่ใช้ visible เพื่อไม่ให้ layout ขยับ
	text_label.visible_characters = 0

	# หาตำแหน่งตัวอักษรของแต่ละบรรทัด (ไม่นับ BBCode และข้ามบรรทัดว่าง)
	var pos := 0
	for line in text_label.get_parsed_text().split("\n"):
		if line.strip_edges() != "":
			_line_starts.append(pos)
			_line_ends.append(pos + line.length())
		pos += line.length() + 1

	await get_tree().create_timer(0.6).timeout
	for step in STEPS:
		await _play_step(step)
	await get_tree().create_timer(1.0).timeout
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)


func _play_step(step: Dictionary) -> void:
	var i: int = step.line
	var count := _line_ends[i] - _line_starts[i]
	_tween = create_tween()
	if step.image >= 0:
		_tween.tween_property(images[step.image], "modulate:a", 1.0, image_fade_time)
	_tween.tween_callback(_start_type_sound)
	_tween.tween_property(text_label, "visible_characters", _line_ends[i], count / chars_per_second).from(_line_starts[i])
	_tween.tween_callback(type_sound.stop)
	_tween.tween_interval(pause_after_line)
	await _tween.finished


func _start_type_sound() -> void:
	# เริ่มจากตำแหน่งสุ่มในไฟล์ เพื่อให้แต่ละบรรทัดเสียงไม่ซ้ำกัน (เหลือท้ายไฟล์ไว้ 3 วินาที)
	var length := type_sound.stream.get_length()
	type_sound.play(randf_range(0.0, maxf(length - 3.0, 0.0)))


# คลิกหรือกด Space/Enter เพื่อข้ามไปก้าวถัดไป
func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.pressed
	if (clicked or event.is_action_pressed("ui_accept")) and _tween and _tween.is_running():
		_tween.custom_step(100.0)
