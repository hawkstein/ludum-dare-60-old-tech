class_name Bleep
extends Resource

@export var extension: String = ""
@export var suffix: String = ""

# Bleep message label
func label() -> String:
	return extension + " " + suffix
