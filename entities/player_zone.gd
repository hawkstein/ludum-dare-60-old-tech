class_name PlayerZone
extends Area3D

signal player_entered

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonPlayer:
		player_entered.emit()

## Is the player currently inside this zone?
func has_player() -> bool:
	return get_overlapping_bodies().any(func(body: Node3D): return body is ThirdPersonPlayer)
