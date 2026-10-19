@tool
class_name Sign
extends Node3D
## A board with text on it, for world signage.

enum ArrowDirection { NONE, LEFT, RIGHT }

const BOARD_DEPTH := 0.05
const TEXT_OFFSET := 0.005
const ARROW_SCALE := 0.6

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

@export var arrow_direction := ArrowDirection.NONE:
	set(value):
		arrow_direction = value
		if is_node_ready():
			_apply_size()

@onready var arrow: Sprite3D = %Arrow

func _ready() -> void:
	label.text = text
	label.font_size = font_size
	_apply_size()
	_apply_color()


func _apply_size() -> void:
	(board.mesh as BoxMesh).size = Vector3(board_size.x, board_size.y, BOARD_DEPTH)
	label.position.z = BOARD_DEPTH / 2 + TEXT_OFFSET
	arrow.position.z = label.position.z
	var usable_width := board_size.x * 0.9
	var arrow_size := board_size.y * ARROW_SCALE
	arrow.visible = arrow_direction != ArrowDirection.NONE
	arrow.flip_h = arrow_direction == ArrowDirection.LEFT
	arrow.pixel_size = arrow_size / arrow.texture.get_height()

	if arrow.visible:
		var side := -1.0 if arrow_direction == ArrowDirection.LEFT else 1.0
		arrow.position.x = side * (usable_width - arrow_size) / 2
		label.position.x = -side * arrow_size / 2
		usable_width -= arrow_size
	else:
		label.position.x = 0.0
	# Width is in pixels, so convert from world units.
	label.width = usable_width / label.pixel_size


func _apply_color() -> void:
	(board.get_surface_override_material(0) as StandardMaterial3D).albedo_color = board_color
