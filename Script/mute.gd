extends TextureButton

@export var icon_on: Texture2D    # รูปตอนมีเสียง
@export var icon_muted: Texture2D # รูปตอนปิดเสียง

func _ready() -> void:
	var bus := AudioServer.get_bus_index("Music")
	set_pressed_no_signal(AudioServer.is_bus_mute(bus))
	_update_icon(button_pressed)
	toggled.connect(_on_toggled)

func _on_toggled(is_muted: bool) -> void:
	var bus := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus, is_muted)
	_update_icon(is_muted)

func _update_icon(is_muted: bool) -> void:
	texture_normal = icon_muted if is_muted else icon_on
