extends Control

@export_file("*.tscn") var next_scene_path := "res://Scenes/two_weeks_later.tscn"   # ← แก้เป็นฉาก cut scene ของคุณ
@export var hint_delay := 2.5    # รอกี่วินาทีก่อนโชว์ข้อความ
@export var blink_time := 0.7    # เวลาครึ่งรอบของการกะพริบ (ยิ่งน้อยยิ่งเร็ว)
@export var blink_min_alpha := 0.25   # ตอนจางสุดเหลือกี่ส่วน (0 = หายเลย)

@onready var power_button: BaseButton = %PowerButton
@onready var hint_label: Label = %HintLabel

var _used := false
var _button_tween: Tween
var _hint_tween: Tween


func _ready() -> void:
	power_button.mouse_entered.connect(UiAudio.play_hover)
	power_button.pressed.connect(UiAudio.play_click)
	power_button.pressed.connect(_on_power_pressed)

	_button_tween = _make_blink(power_button)

	# ข้อความ: รอ -> ค่อยๆ ขึ้น -> เริ่มกะพริบ
	hint_label.modulate.a = 0.0
	_hint_tween = create_tween()
	_hint_tween.tween_interval(hint_delay)
	_hint_tween.tween_property(hint_label, "modulate:a", 1.0, 1.0)
	_hint_tween.tween_callback(func(): _hint_tween = _make_blink(hint_label))


func _make_blink(node: CanvasItem) -> Tween:
	var t := create_tween().set_loops()
	t.tween_property(node, "modulate:a", blink_min_alpha, blink_time).set_trans(Tween.TRANS_SINE)
	t.tween_property(node, "modulate:a", 1.0, blink_time).set_trans(Tween.TRANS_SINE)
	return t


func _on_power_pressed() -> void:
	if _used:
		return
	_used = true
	if _button_tween:
		_button_tween.kill()
	if _hint_tween:
		_hint_tween.kill()
	power_button.modulate.a = 1.0
	hint_label.modulate.a = 0.0   # ซ่อนข้อความตอนกดปุ่ม
	Transition.change_scene(next_scene_path)
