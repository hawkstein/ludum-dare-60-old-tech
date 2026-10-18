class_name GameplayData
extends DataModel

var show_instructions := true
var mouse_sensitivity := 0.3

func _init() -> void:
	set_meta("title", "Gameplay")
	set_meta("show_instructions", PropertyMeta.new("Instructions"))
	set_meta("mouse_sensitivity", SliderMeta.new("Mouse Sensitivity", 0.05, 1.0, 0.05))
