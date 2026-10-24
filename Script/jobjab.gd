extends Control

@onready var Do_Test_button : BaseButton = $TextureRect/Start_Test

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for b in [Do_Test_button]:
		b.pressed.connect(UiAudio.play_click)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_start_test_pressed() -> void:
	Transition.change_scene("res://Scenes/pre_test.tscn")
