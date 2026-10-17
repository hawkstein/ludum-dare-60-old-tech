extends Node
## Per-run game state: values, story flags and collected IDs. Cleared on a new run, never saved.

signal value_changed(key: StringName, value: Variant)
signal flag_changed(key: StringName, on: bool)

var _values: Dictionary[StringName, Variant] = {}
var _flags: Dictionary[StringName, bool] = {}
var _collected: Dictionary[StringName, bool] = {}

## Return a run value, or default if it was never set.
func get_value(key: StringName, default: Variant = null) -> Variant:
	return _values.get(key, default)


## Set a run value.
func set_value(key: StringName, value: Variant) -> void:
	_values[key] = value
	value_changed.emit(key, value)


## Add to a numeric run value (starting from 0) and return the new total.
func add(key: StringName, amount: Variant) -> Variant:
	var total: Variant = _values.get(key, 0) + amount
	set_value(key, total)
	return total


## Turn a story flag on or off.
func set_flag(key: StringName, on := true) -> void:
	if has_flag(key) == on:
		return
	_flags[key] = on
	flag_changed.emit(key, on)


## Whether a story flag is on.
func has_flag(key: StringName) -> bool:
	return _flags.get(key, false)


## Record an ID as collected for this run.
func mark_collected(id: StringName) -> void:
	_collected[id] = true


## Whether an ID was collected this run.
func is_collected(id: StringName) -> bool:
	return _collected.has(id)


## Clear all state for a new run.
func reset() -> void:
	_values.clear()
	_flags.clear()
	_collected.clear()
