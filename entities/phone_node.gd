extends Node3D

@export var spin_speed := 1.5  # rad/s

func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)
