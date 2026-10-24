extends Control
# Scene: two_weeks_later.tscn
# ลำดับ:
#   จอดำ -> "2 อาทิตย์ผ่านไป" (ตัวใหญ่กลางจอ)
#   -> cutscene 3 ภาพ + ข้อความพิมพ์ทีละตัว -> [Space]
#   -> ภาพฉลอง + บทพูด HR 2 หน้า (หน้าละ [Space])
#   -> fade ดำ -> ไปหน้า "Lesson D1 / Phishing Detection"

signal _accepted

# ---------- Nodes ----------
@onready var bg: ColorRect = $ColorRect
@onready var images: Array[TextureRect] = [
	$ColorRect/HBoxContainer/ImageHolder/TextureRect,
	$ColorRect/HBoxContainer/ImageHolder/TextureRect2,
	$ColorRect/HBoxContainer/ImageHolder/TextureRect3,
]
@onready var text_label: RichTextLabel = $ColorRect/RichTextLabel
@onready var continue_label: RichTextLabel = $ColorRect/RichTextLabel/ContinueLabel
@onready var title_label: Label = $TitleLabel
@onready var type_sound: AudioStreamPlayer = $Typesound

@onready var celebration: Control = $Celebration
@onready var hr_text: RichTextLabel = $Celebration/Bottom/DialogBox/MarginContainer/TextLabel
@onready var hr_continue: Control = $Celebration/ContinueLabel

# ---------- Settings ----------
const NEXT_SCENE := "res://Scenes/lesson_d1_title.tscn"  # แก้ให้ตรง path จริง
const TYPE_DELAY := 0.04

const TITLE_TEXT := "2 อาทิตย์ผ่านไป"
const TITLE_FADE_IN := 1.0
const TITLE_HOLD := 1.8
const TITLE_FADE_OUT := 1.0

# ส่วน cutscene: 1 รายการ = 1 จังหวะ (ภาพที่ i โผล่พร้อมข้อความจังหวะที่ i)
const BEATS := [
	"คุณตื่นขึ้นมาในตอนเช้า และทำกิจวัตรประจำวันตามปกติ\n",
	"จนกระทั่งเวลา 10:47 น. เสียงแจ้งเตือนก็ดังขึ้น\n",
	"มีอีเมลส่งมาจากบริษัท POK POK CO. คุณจึงเปิดข้อความนั้นขึ้นมาอ่าน...",
]

# ส่วน HR: 1 รายการ = 1 หน้าของกล่องบทพูด
const HR_PAGES := [
	"ยินดีด้วยค่ะ! ทางบริษัทได้คัดเลือกคุณเข้าร่วมทีม\nในตำแหน่ง SOC Analyst",
	"ขอบคุณที่มาเป็นส่วนหนึ่งของ Pok Pok Co. นะคะ\nคุณสามารถเริ่มงานได้เลยนะคะ",
]

var _typing := false
var _skip := false
var _waiting := false


func _ready() -> void:
	for img in images:
		img.modulate.a = 0.0
	text_label.text = "".join(BEATS)
	text_label.visible_characters = 0
	continue_label.visible = false

	title_label.text = TITLE_TEXT
	title_label.modulate.a = 0.0

	celebration.modulate.a = 0.0     # ซ่อนด้วยความโปร่งใส (อยู่เหนือ ColorRect แต่มองไม่เห็นจนกว่าจะ fade เข้า)
	hr_text.text = ""
	hr_continue.visible = false

	# ไฟล์เสียงยาว 8 วิ: ถ้าเสียงจบก่อนพิมพ์เสร็จ ให้เล่นซ้ำต่อ
	type_sound.finished.connect(_on_type_sound_finished)

	_play()


func _play() -> void:
	await _play_title()
	await _play_cutscene()
	await _play_celebration()
	get_tree().change_scene_to_file(NEXT_SCENE)


# ---------------- 1) ตัวหนังสือกลางจอ ----------------
func _play_title() -> void:
	var t := create_tween()
	t.tween_property(title_label, "modulate:a", 1.0, TITLE_FADE_IN)
	t.tween_interval(TITLE_HOLD)
	t.tween_property(title_label, "modulate:a", 0.0, TITLE_FADE_OUT)
	await t.finished
	await get_tree().create_timer(0.5).timeout


# ---------------- 2) cutscene 3 ภาพ ----------------
func _play_cutscene() -> void:
	var shown := 0
	for i in BEATS.size():
		var fade_in := create_tween()
		fade_in.tween_property(images[i], "modulate:a", 1.0, 0.8)
		var length: int = BEATS[i].length()
		await _type(text_label, shown, shown + length)
		shown += length
		await get_tree().create_timer(0.6).timeout
	await _wait_accept(continue_label)


# ---------------- 3) ภาพฉลอง + บทพูด HR ----------------
func _play_celebration() -> void:
	# cutscene ค่อยๆ มืด แล้วภาพฉลองค่อยๆ ขึ้น
	var t := create_tween()
	t.tween_property(bg, "modulate", Color.BLACK, 0.8)
	t.tween_property(celebration, "modulate:a", 1.0, 0.8)
	await t.finished
	await get_tree().create_timer(0.4).timeout

	for page in HR_PAGES:
		hr_text.text = page
		hr_text.visible_characters = 0
		await _type(hr_text, 0, hr_text.get_total_character_count())
		await _wait_accept(hr_continue)

	# จบ: ภาพฉลองค่อยๆ มืดลง
	var out := create_tween()
	out.tween_property(celebration, "modulate", Color.BLACK, 0.8)
	await out.finished


# ---------------- Helpers ----------------
func _type(label: RichTextLabel, from: int, to: int) -> void:
	_typing = true
	_skip = false
	type_sound.play(randf_range(0.0, 2.0))
	for c in range(from, to):
		if _skip:
			break
		label.visible_characters = c + 1
		await get_tree().create_timer(TYPE_DELAY).timeout
	label.visible_characters = to
	type_sound.stop()
	_typing = false


func _on_type_sound_finished() -> void:
	if _typing:
		type_sound.play()


func _wait_accept(prompt: Control) -> void:
	prompt.visible = true
	prompt.modulate.a = 1.0
	var blink := create_tween().set_loops()
	blink.tween_property(prompt, "modulate:a", 0.2, 0.6)
	blink.tween_property(prompt, "modulate:a", 1.0, 0.6)
	_waiting = true
	await _accepted
	_waiting = false
	blink.kill()
	prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):   # Space / Enter
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_skip = true          # กดระหว่างพิมพ์ = ข้ามให้พิมพ์จบทันที
	elif _waiting:
		_accepted.emit()
