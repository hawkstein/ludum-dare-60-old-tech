class_name ChoiceScreen
extends CanvasLayer
## Modal screen with a title, body text and choices.

signal chosen(index: int)

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel
@onready var choices_box: VBoxContainer = %Choices

var _paused_game := false
var _previous_mouse_mode: Input.MouseMode

func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	# Stop the pause menu opening on top and unpausing underneath. Could couple together later.
	if visible and event.is_action_pressed(&"Pause"):
		get_viewport().set_input_as_handled()


## Show the screen. Each choice is {label, action}; action is a Callable or a ScreenChanger key.
func present(title: String, body: String, choices: Array[Dictionary], pause_game := true) -> void:
	title_label.text = title
	body_label.text = body
	body_label.visible = not body.is_empty()

	for child in choices_box.get_children():
		choices_box.remove_child(child)
		child.queue_free()
	for i in choices.size():
		var button := FancyButton.new()
		button.text = choices[i].label
		button.pressed.connect(_on_choice_pressed.bind(choices[i].action, i))
		choices_box.add_child(button)

	_paused_game = pause_game
	if pause_game:
		get_tree().paused = true
	_previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	if choices_box.get_child_count() > 0:
		choices_box.get_child(0).grab_focus()


func _on_choice_pressed(action: Variant, index: int) -> void:
	hide()
	Input.mouse_mode = _previous_mouse_mode
	if _paused_game:
		get_tree().paused = false
	chosen.emit(index)
	if action is Callable:
		action.call()
	elif action is StringName or action is String:
		ScreenChanger.change_to(action)
