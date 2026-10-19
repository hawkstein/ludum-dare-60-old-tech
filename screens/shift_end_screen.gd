extends Control
## Success / failure screen: score card from RunState, then play again or main menu.

## Also show how many of each severity were missed.
@export var show_missed := true

@onready var score_label: Label = %ScoreLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var tips_button: Button = %TipsButton

func _ready() -> void:
	# Arriving from gameplay, where the mouse is captured.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	if tips_button:
		tips_button.pressed.connect(_on_tips_pressed)
	score_label.text = _build_score_text()
	play_again_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_on_main_menu_pressed()
		get_viewport().set_input_as_handled()


func _build_score_text() -> String:
	var lines: PackedStringArray = []
	for severity in Bleep.Severity.values():
		var score: Dictionary = RunState.get_value(&"score_%d" % severity, {})
		if score.get("total", 0) == 0:
			continue
		var line := "%s events  %d/%d" % [
			Bleep.Severity.keys()[severity].capitalize(), score.get("resolved", 0), score.total]
		if show_missed and score.get("failed", 0) > 0:
			line += "  (%d missed)" % score.failed
		lines.append(line)
	return "\n".join(lines)


func _on_play_again_pressed() -> void:
	RunState.reset()
	ScreenChanger.change_to(&"main")


func _on_main_menu_pressed() -> void:
	ScreenChanger.change_to(&"main_menu")
	

func _on_tips_pressed() -> void:
	ScreenChanger.change_to(&"tips")
