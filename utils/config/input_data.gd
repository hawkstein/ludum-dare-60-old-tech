class_name InputData
extends DataModel

var up_events:Array[String] = ["W", "UP"]
var down_events:Array[String] = ["S", "DOWN"]
var left_events:Array[String] = ["A", "LEFT"]
var right_events:Array[String] = ["D", "RIGHT"]
var jump_events:Array[String] = ["SPACE"]
var pause_events:Array[String] = ["P"]
var pager_events:Array[String] = ["Y"]

const JOY_DEFAULTS := {
	&"Up": [[JOY_AXIS_LEFT_Y, -1.0], JOY_BUTTON_DPAD_UP],
	&"Down": [[JOY_AXIS_LEFT_Y, 1.0], JOY_BUTTON_DPAD_DOWN],
	&"Left": [[JOY_AXIS_LEFT_X, -1.0], JOY_BUTTON_DPAD_LEFT],
	&"Right": [[JOY_AXIS_LEFT_X, 1.0], JOY_BUTTON_DPAD_RIGHT],
	&"Jump": [JOY_BUTTON_A],
	&"Pause": [JOY_BUTTON_START],
	&"LookUp": [[JOY_AXIS_RIGHT_Y, -1.0]],
	&"LookDown": [[JOY_AXIS_RIGHT_Y, 1.0]],
	&"LookLeft": [[JOY_AXIS_RIGHT_X, -1.0]],
	&"LookRight": [[JOY_AXIS_RIGHT_X, 1.0]],
	&"Pager": [JOY_BUTTON_Y],
}

func _init() -> void:
	set_meta("title", "Input")
	set_meta("up_events", PropertyMeta.new("Up"))
	set_meta("down_events", PropertyMeta.new("Down"))
	set_meta("left_events", PropertyMeta.new("Left"))
	set_meta("right_events", PropertyMeta.new("Right"))
	set_meta("jump_events", PropertyMeta.new("Jump"))
	set_meta("pause_events", PropertyMeta.new("Pause"))
	set_meta("pager_events", PropertyMeta.new("Pager"))

## Rebuild the InputMap from the saved keys and gamepad defaults.
func apply() -> void:
	var keys_by_action := {}
	for prop in get_property_list():
		if prop.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var meta = get_meta(prop.name) as PropertyMeta
			keys_by_action[StringName(meta.label)] = get(prop.name)
	for action in JOY_DEFAULTS:
		keys_by_action.get_or_add(action, [])

	for action in keys_by_action:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		for key in keys_by_action[action]:
			InputMap.action_add_event(action, _key_event(key))
		for binding in JOY_DEFAULTS.get(action, []):
			InputMap.action_add_event(action, _joy_event(binding))

## Swap one key for another or add if the old key isn't bound.
func update(value:Variant, property_name:StringName) -> void:
	var events = get(property_name) as Array[String]
	var idx = events.find(value.previous_keycode)
	if idx == -1:
		events.append(value.keycode_as_string)
	else:
		events[idx] = value.keycode_as_string
	apply()
	super.update(events, property_name)


func _key_event(key:String) -> InputEventKey:
	var event = InputEventKey.new()
	event.keycode = OS.find_keycode_from_string(key)
	return event

func _joy_event(binding:Variant) -> InputEvent:
	var event:InputEvent
	if binding is Array:
		event = InputEventJoypadMotion.new()
		event.axis = binding[0]
		event.axis_value = binding[1]
	else:
		event = InputEventJoypadButton.new()
		event.button_index = binding
	event.device = -1 # any controller
	return event
