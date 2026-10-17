class_name PauseMenu
extends CanvasLayer

signal paused_changed(paused: bool)

@onready var title_window: Control = %TitleWindow

var _close_button: Button
var _was_captured := false
var resume_mouse_mode := Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	_build_content()
	_close_button = title_window.find_child("CloseButton") as Button
	title_window.close_window.connect(set_paused.bind(false))
	hide()


func _process(_delta: float) -> void:
	# Watching for browser change.
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if resume_mouse_mode == Input.MOUSE_MODE_CAPTURED and _was_captured and not captured and not get_tree().paused:
		set_paused(true)
	_was_captured = captured


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not visible:
		set_paused(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Pause"):
		toggle()
	elif event.is_action_pressed(&"ui_cancel") and visible:
		set_paused(false)
	else:
		return
	get_viewport().set_input_as_handled()


## Switch between paused and playing.
func toggle() -> void:
	set_paused(not visible)


## Pause or resume the game.
func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else resume_mouse_mode
	if paused and _close_button:
		_close_button.grab_focus()
	paused_changed.emit(paused)


func _build_content() -> void:
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var sections := HBoxContainer.new()
	sections.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var builder := UIBuilder.new()
	for key in [&"Audio", &"Gameplay"]:
		sections.add_child(builder.build_section_from_model(DataStore.get_model(key)))
	layout.add_child(sections)

	var main_menu_button := Button.new()
	main_menu_button.text = "Main Menu"
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	layout.add_child(main_menu_button)

	title_window.add_content(layout)


func _on_main_menu_pressed() -> void:
	# Fade addon needs tree to unpause. Consider resolving this
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ScreenChanger.change_to(&"main_menu")
