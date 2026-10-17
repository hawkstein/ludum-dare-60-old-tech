extends Button
class_name RemapButton

signal keycode_updated(update:Dictionary)

var keycode_as_string:String = ""

func _init(event_code:String):
	toggle_mode = true
	theme_type_variation = "RemapButton"
	keycode_as_string = event_code


func _ready():
	set_process_input(false)
	update_key_text()


func _toggled(toggled_on:bool):
	set_process_input(toggled_on)
	if toggled_on:
		text = " ? "
		release_focus()
	else:
		update_key_text()
		grab_focus()



func _input(event:InputEvent):
	if event is InputEventMouseButton and event.pressed:
		button_pressed = false # any click cancels
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode and event.keycode != KEY_ESCAPE: # Escape cancels
			var previous_keycode = keycode_as_string
			keycode_as_string = OS.get_keycode_string(event.keycode)
			var update := {
				"previous_keycode": previous_keycode,
				"keycode_as_string": keycode_as_string,
			}
			keycode_updated.emit(update)
		button_pressed = false
	else:
		return
	get_viewport().set_input_as_handled()


## Show the bound key on the button.
func update_key_text():
	text = keycode_as_string
