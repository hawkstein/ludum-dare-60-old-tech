extends Control

@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()


func _on_back_button_pressed() -> void:
	ScreenChanger.change_to("main_menu")
