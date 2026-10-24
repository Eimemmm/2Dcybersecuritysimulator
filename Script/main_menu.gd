extends Control

@onready var name_dialog: Control = $NameInput
@onready var name_edit: LineEdit = $NameInput/Panel/VBoxContainer/LineEdit
@onready var start_button: BaseButton = $ContainnerCenter/Start
@onready var exit_button: BaseButton = $ContainnerCenter/Exit
@onready var mute_button: TextureButton = $Mute
@onready var confirm_button: BaseButton = $NameInput/Panel/VBoxContainer/HBoxContainer/Confirm
@onready var back_button: BaseButton = $NameInput/Panel/VBoxContainer/HBoxContainer/Back

var _regex := RegEx.new()
var _submitting := false


func _ready() -> void:
	name_edit.max_length = 16
	_regex.compile("[^A-Za-z0-9]")

	_connect_once(name_edit.text_submitted, _on_name_submitted)   # กด Enter
	_connect_once(name_edit.text_changed, _on_name_changed)

	for b in [start_button, exit_button, mute_button, confirm_button, back_button]:
		_connect_once(b.mouse_entered, UiAudio.play_hover)
		_connect_once(b.pressed, UiAudio.play_click)

	_connect_once(start_button.pressed, _on_start_pressed)
	_connect_once(exit_button.pressed, _on_exit_pressed)
	_connect_once(confirm_button.pressed, _on_confirm_pressed)
	_connect_once(back_button.pressed, _close_name_dialog)


# ต่อสัญญาณเฉพาะเมื่อยังไม่เคยต่อ (กัน error "already connected")
func _connect_once(sig: Signal, callable: Callable) -> void:
	if not sig.is_connected(callable):
		sig.connect(callable)


func _on_name_changed(new_text: String) -> void:
	var cleaned := _regex.sub(new_text, "", true)   # true = ลบทุกตัวที่เจอ
	if cleaned != new_text:
		var pos := name_edit.caret_column - (new_text.length() - cleaned.length())
		name_edit.text = cleaned
		name_edit.caret_column = maxi(pos, 0)        # คืนตำแหน่งเคอร์เซอร์


func _on_start_pressed() -> void:
	name_dialog.show()
	name_edit.grab_focus()


func _input(event: InputEvent) -> void:
	if name_dialog.visible and event.is_action_pressed("ui_cancel"):
		_close_name_dialog()
		get_viewport().set_input_as_handled()


func _close_name_dialog() -> void:
	name_dialog.hide()
	name_edit.clear()          # เคลียร์ชื่อที่พิมพ์ค้างไว้ (ลบบรรทัดนี้ถ้าอยากให้จำไว้)
	name_edit.release_focus()


func _on_exit_pressed() -> void:
	await get_tree().create_timer(0.2).timeout   # รอให้เสียงคลิกเล่นจบ
	get_tree().quit()


func _on_confirm_pressed() -> void:
	_on_name_submitted(name_edit.text)


func _on_name_submitted(text: String) -> void:
	if _submitting:
		return
	var player_name := text.strip_edges()
	if player_name.is_empty():
		return                                   # หรือแสดงข้อความเตือน
	_submitting = true
	GameState.player_name = player_name
	Transition.change_scene("res://Scenes/Intro.tscn")
