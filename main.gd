extends Node3D

@onready var messages: MessageLayer = $MessageLayer

func _ready() -> void:
	messages.show_message("They were, of course,  in a template", "Narrator")
