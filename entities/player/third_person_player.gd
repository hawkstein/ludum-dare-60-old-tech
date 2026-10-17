class_name ThirdPersonPlayer
extends CharacterBody3D

const MOUSE_SCALE := 0.01

@export var speed := 6.0
@export var acceleration := 12.0
@export var turn_speed := 12.0
@export var jump_velocity := 4.5
## Radians per second at full stick.
@export var pad_look_speed := 3.0
## Camera pitch range in degrees (down, up).
@export var pitch_limits := Vector2(-70, 30)

@onready var model: Node3D = %Model
@onready var camera_pivot: Node3D = %CameraPivot
@onready var spring_arm: SpringArm3D = %SpringArm3D

var gameplay := DataStore.get_model(&"Gameplay") as GameplayData

func _ready() -> void:
	spring_arm.add_excluded_object(get_rid())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * gameplay.mouse_sensitivity * MOUSE_SCALE)


func _physics_process(delta: float) -> void:
	var stick := Input.get_vector(&"LookLeft", &"LookRight", &"LookUp", &"LookDown")
	if stick:
		_look(stick * pad_look_speed * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta
	elif Input.is_action_just_pressed(&"Jump"):
		velocity.y = jump_velocity

	var input := Input.get_vector(&"Left", &"Right", &"Up", &"Down")
	var direction := Basis(Vector3.UP, camera_pivot.global_rotation.y) * Vector3(input.x, 0, input.y)
	var weight := 1.0 - exp(-acceleration * delta)
	velocity.x = lerpf(velocity.x, direction.x * speed, weight)
	velocity.z = lerpf(velocity.z, direction.z * speed, weight)

	if direction:
		var facing := atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, facing, 1.0 - exp(-turn_speed * delta))

	move_and_slide()


func _look(amount: Vector2) -> void:
	if gameplay.invert_y:
		amount.y = -amount.y
	camera_pivot.rotation.y -= amount.x
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - amount.y, deg_to_rad(pitch_limits.x), deg_to_rad(pitch_limits.y))
