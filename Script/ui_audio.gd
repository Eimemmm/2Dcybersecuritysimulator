extends Node

var _hover := AudioStreamPlayer.new()
var _click := AudioStreamPlayer.new()

func _ready() -> void:
	_hover.stream = preload("res://Audio/Hover.mp3")
	_click.stream = preload("res://Audio/Click.mp3")
	_hover.bus = "SFX"
	_click.bus = "SFX"
	add_child(_hover)
	add_child(_click)
	_hover.volume_db = -5
	_click.volume_db = -6

func play_hover() -> void:
	_hover.play()

func play_click() -> void:
	_click.play()
