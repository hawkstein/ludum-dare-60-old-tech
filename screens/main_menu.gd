extends Control

const TWEEN_DURATION := 0.6
const SLIDE_DISTANCE := 300.0

@onready var start_container: VBoxContainer = $MarginContainer/StartVBoxContainer
@onready var options_container: HBoxContainer = $MarginContainer/OptionsVBoxContainer/HBoxContainer
@onready var options_v_box_container: VBoxContainer = $MarginContainer/OptionsVBoxContainer
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton
@onready var menu: Container = %Menu

var _transition_tween: Tween
var _current: Control
var _leaving: Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var builder := UIBuilder.new()
	var audio_section = builder.build_section_from_model(DataStore.get_model("Audio"))
	options_container.add_child(audio_section)
	var gameplay_section = builder.build_section_from_model(DataStore.get_model("Gameplay"))
	options_container.add_child(gameplay_section)
	var input_section = builder.build_section_from_model(DataStore.get_model("Input"))
	options_container.add_child(input_section)
	
	menu.modulate.a = 0.0
	var menu_tween = create_tween()
	menu_tween.tween_property(menu, "modulate:a", 1.0, 0.6).set_delay(0.9)

	start_container.show()
	options_v_box_container.hide()
	_current = start_container
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and _current == options_v_box_container:
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()


func _switch_panels(from: Control, to: Control, direction: float, focus_target: Control) -> void:
	if _transition_tween:
		_transition_tween.kill()
		
	if _leaving and _leaving != from and _leaving != to:
		_leaving.hide()

	from.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	from.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	to.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	to.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED

	if not to.visible:
		to.modulate.a = 0.0
		to.offset_transform_position.x = SLIDE_DISTANCE * direction
	to.show()
	focus_target.grab_focus()
	_current = to
	_leaving = from

	_transition_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	_transition_tween.tween_property(from, "modulate:a", 0.0, TWEEN_DURATION)
	_transition_tween.tween_property(from, "offset_transform_position:x", -SLIDE_DISTANCE * direction, TWEEN_DURATION)
	_transition_tween.tween_property(to, "modulate:a", 1.0, TWEEN_DURATION)
	_transition_tween.tween_property(to, "offset_transform_position:x", 0.0, TWEEN_DURATION)
	_transition_tween.chain().tween_callback(_finish_leaving.bind(from))


func _finish_leaving(panel: Control) -> void:
	panel.hide()
	_leaving = null


func _on_start_button_pressed() -> void:
	RunState.reset()
	ScreenChanger.change_to(&"instructions")


func _on_options_button_pressed() -> void:
	_switch_panels(start_container, options_v_box_container, 1.0, back_button)


func _on_back_button_pressed() -> void:
	_switch_panels(options_v_box_container, start_container, -1.0, start_button)


func _on_credits_button_pressed() -> void:
	ScreenChanger.change_to(&"instructions")
