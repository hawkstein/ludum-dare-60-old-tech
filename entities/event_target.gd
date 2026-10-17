class_name EventTarget
extends PlayerZone

@export var target_id: StringName

func _ready() -> void:
	super()
	add_to_group(&"event_targets")
