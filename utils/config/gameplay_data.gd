class_name GameplayData
extends DataModel

var show_instructions := true
var mouse_sensitivity := 0.3
var message_duration := 4.0

func _init() -> void:
	set_meta("title", "Gameplay")
	set_meta("show_instructions", PropertyMeta.new("Instructions"))
	set_meta("mouse_sensitivity", SliderMeta.new("Mouse Sensitivity", 0.05, 1.0, 0.05))
	set_meta("message_duration", SliderMeta.new("Message Time", 2.0, 8.0, 0.5))
