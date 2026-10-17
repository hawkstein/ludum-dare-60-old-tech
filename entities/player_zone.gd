class_name PlayerZone
extends Area3D

signal player_entered

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonPlayer:
		player_entered.emit()
