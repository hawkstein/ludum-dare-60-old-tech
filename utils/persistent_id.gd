class_name PersistentId
extends Node
## Keeps its parent removed for the rest of the run once collected.

## Leave empty to use the scene file and node path. Set it for anything spawned at runtime.
@export var id: StringName

func _ready() -> void:
	if id.is_empty():
		id = _build_id()
	if RunState.is_collected(id):
		get_parent().queue_free()


## Mark the parent as collected so it stays gone on reload.
func collect() -> void:
	RunState.mark_collected(id)


func _build_id() -> StringName:
	var scene_root := get_parent()
	while scene_root.owner:
		scene_root = scene_root.owner
	return StringName("%s:%s" % [scene_root.scene_file_path, scene_root.get_path_to(get_parent())])
