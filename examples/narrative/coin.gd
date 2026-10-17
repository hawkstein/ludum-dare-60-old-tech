extends Area3D
## Spinning coin that adds to the run's coin count and stays collected on reload.

@export var spin_speed := 2.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)


func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonPlayer:
		%PersistentId.collect()
		RunState.add(&"coins", 1)
		queue_free()
