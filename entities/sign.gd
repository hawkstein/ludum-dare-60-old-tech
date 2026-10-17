@tool
class_name Sign
extends Node3D
## A board with text on it, for world signage.

const BOARD_DEPTH := 0.05
const TEXT_OFFSET := 0.005

@export_multiline var text := "Sign":
	set(value):
		text = value
		if is_node_ready():
			label.text = value
@export var board_size := Vector2(1.6, 0.8):
	set(value):
		board_size = value
		if is_node_ready():
			_apply_size()
@export_range(8, 256) var font_size := 64:
	set(value):
		font_size = value
		if is_node_ready():
			label.font_size = value
@export var board_color := Color(0.16470589, 0.39215687, 0.21568628):
	set(value):
		board_color = value
		if is_node_ready():
			_apply_color()

@onready var board: MeshInstance3D = %Board
@onready var label: Label3D = %Text

func _ready() -> void:
	label.text = text
	label.font_size = font_size
	_apply_size()
	_apply_color()


func _apply_size() -> void:
	(board.mesh as BoxMesh).size = Vector3(board_size.x, board_size.y, BOARD_DEPTH)
	label.position.z = BOARD_DEPTH / 2 + TEXT_OFFSET
	# Width is in pixels, so convert from world units.
	label.width = (board_size.x * 0.9) / label.pixel_size


func _apply_color() -> void:
	(board.get_surface_override_material(0) as StandardMaterial3D).albedo_color = board_color
