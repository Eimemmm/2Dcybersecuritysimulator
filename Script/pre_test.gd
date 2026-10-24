extends Control


@export_file("*.json") var questions_path := "res://Data/questions.json"
@export_file("*.tscn") var next_scene_path := "res://Scenes/pre_test_success.tscn"
@export var is_post_test := false

@onready var header: Label = %Header
@onready var question_label: RichTextLabel = %Question
@onready var exhibit_panel: PanelContainer = %ExhibitPanel
@onready var exhibit_label: RichTextLabel = %ExhibitLabel
@onready var choice_buttons: Array[Button] = [%ChoiceA, %ChoiceB, %ChoiceC, %ChoiceD]
@onready var next_button: Button = %NextButton

var questions: Array = []
var shuffled: Array = []
var results: Array = []
var index := 0
var selected := -1


func _ready() -> void:
	var file := FileAccess.open(questions_path, FileAccess.READ)
	questions = JSON.parse_string(file.get_as_text())
	for i in choice_buttons.size():
		choice_buttons[i].pressed.connect(_on_choice.bind(i))
		choice_buttons[i].pressed.connect(UiAudio.play_click)
	next_button.pressed.connect(_on_next)
	next_button.pressed.connect(UiAudio.play_click)
	_show_question()

func _show_question() -> void:
	var q: Dictionary = questions[index]
	header.text = "Application Assessment (%d/%d)" % [index + 1, questions.size()]
	question_label.text = q["question"]

	var exhibit: String = q.get("exhibit", "")
	exhibit_panel.visible = exhibit != ""
	exhibit_label.text = exhibit

	# สุ่มลำดับตัวเลือกทุกครั้ง
	shuffled = q["choices"].duplicate()
	shuffled.shuffle()
	for i in choice_buttons.size():
		choice_buttons[i].text = shuffled[i]
		choice_buttons[i].set_pressed_no_signal(false)

	selected = -1
	next_button.visible = false
	next_button.text = "ส่งใบสมัคร" if index == questions.size() - 1 else "Next"


func _on_choice(i: int) -> void:
	selected = i
	next_button.visible = true


func _on_next() -> void:
	if index >= questions.size():
		return
	var q: Dictionary = questions[index]
	var correct_text: String = q["choices"][int(q["answer"])]
	results.append({"stage": q["stage"], "correct": shuffled[selected] == correct_text})
	index += 1
	if index < questions.size():
		_show_question()
	else:
		_finish()


func _finish() -> void:
	next_button.disabled = true
	var scores := {}
	for r in results:
		scores[r["stage"]] = scores.get(r["stage"], 0) + (1 if r["correct"] else 0)
	if is_post_test:
		GameState.posttest_scores = scores
	else:
		GameState.pretest_scores = scores
	if next_scene_path != "":
		Transition.change_scene(next_scene_path)
