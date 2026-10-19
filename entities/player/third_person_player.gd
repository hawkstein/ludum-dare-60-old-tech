class_name ThirdPersonPlayer
extends CharacterBody3D

const MOUSE_SCALE := 0.01

@export var speed := 8.0
@export var acceleration := 12.0
@export var turn_speed := 12.0
## Radians per second at full stick.
@export var pad_look_speed := 3.0
## Fixed camera pitch in degrees, looking down over the shoulder.
@export var pitch := -30.0

@onready var model: Node3D = %Model
@onready var camera_pivot: Node3D = %CameraPivot
@onready var spring_arm: SpringArm3D = %SpringArm3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var gameplay := DataStore.get_model(&"Gameplay") as GameplayData
var input_enabled := true

func _ready() -> void:
	spring_arm.add_excluded_object(get_rid())
	camera_pivot.rotation.x = deg_to_rad(pitch)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled: return
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative.x * gameplay.mouse_sensitivity * MOUSE_SCALE)


func _physics_process(delta: float) -> void:
	var stick := Input.get_axis(&"LookLeft", &"LookRight") if input_enabled else 0.0
	if stick:
		_look(stick * pad_look_speed * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input := Input.get_vector(&"Left", &"Right", &"Up", &"Down") if input_enabled else Vector2.ZERO
	var direction := Basis(Vector3.UP, camera_pivot.global_rotation.y) * Vector3(input.x, 0, input.y)
	var weight := 1.0 - exp(-acceleration * delta)
	velocity.x = lerpf(velocity.x, direction.x * speed, weight)
	velocity.z = lerpf(velocity.z, direction.z * speed, weight)

	if direction:
		var facing := atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, facing, 1.0 - exp(-turn_speed * delta))

	move_and_slide()
	_animate()


func _look(amount: float) -> void:
	camera_pivot.rotation.y -= amount
	
func _animate() -> void:
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	if ground_speed > 2.0:
		anim_player.play(&"run", 0.2)
		anim_player.speed_scale = maxf(ground_speed / speed, 0.6)
	elif anim_player.current_animation != &"idle":
		anim_player.speed_scale = 1.0
		anim_player.play_with_capture(&"idle", 0.35, -1, 1.0, false, Tween.TRANS_BACK, Tween.EASE_OUT)
