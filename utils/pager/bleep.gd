class_name Bleep
extends Resource

enum Severity { NORMAL, CRITICAL }

@export var extension: String = ""
@export var suffix: String = ""

@export_group("Phone")
@export_multiline var message := ""

@export_group("Event")
## EventTarget's target_id: &"ward3_bed1"
@export var target_id: StringName
@export var time_limit := 20.0
@export var severity := Severity.NORMAL

# Bleep message label
func label() -> String:
	return extension + " " + suffix
