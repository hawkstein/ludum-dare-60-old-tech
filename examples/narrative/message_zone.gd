extends Area3D
## Shows a message the first time the player enters, once per scene load.

@export var messages: MessageLayer
@export_multiline var text := ""
@export var speaker := ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonPlayer:
		messages.show_message(text, speaker)
		set_deferred("monitoring", false)
