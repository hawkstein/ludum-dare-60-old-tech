extends Node

@export var screens:Dictionary[StringName, PackedScene] = {}

func change_to(key:StringName) -> void:
	if not screens.has(key):
		push_warning("Key does not exist: ", key)
		return
	if not is_inside_tree():
		push_error("Current node is not in the scene tree")
		return
	call_deferred("_deferred_change_to", key)

func _deferred_change_to(key:StringName) -> void:
	await Fade.fade_out().finished
	get_tree().change_scene_to_packed(screens[key])
	Fade.fade_in()
