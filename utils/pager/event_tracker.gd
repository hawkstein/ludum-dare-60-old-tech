class_name EventTracker
extends Node
## Follows each bleep's event from send to resolution.

signal event_resolved(bleep: Bleep)
signal event_failed(bleep: Bleep, severity: Bleep.Severity)

@export var messages: MessageLayer

class ActiveEvent:
	var bleep: Bleep
	var time_left: float
	var heard := false

	func _init(p_bleep: Bleep) -> void:
		bleep = p_bleep
		time_left = p_bleep.time_limit

var _active: Array[ActiveEvent] = []
var _targets: Dictionary[StringName, EventTarget] = {}
var resolved: Dictionary[int, int] = {}
var failed: Dictionary[int, int] = {}

func _ready() -> void:
	for phone:PlayerZone in get_tree().get_nodes_in_group(&"phones"):
		phone.player_entered.connect(_on_phone_reached)


func _process(delta: float) -> void:
	for event in _active.duplicate():
		event.time_left -= delta
		if event.time_left <= 0.0:
			_active.erase(event)
			failed[event.bleep.severity] = failed.get(event.bleep.severity, 0) + 1
			event_failed.emit(event.bleep, event.bleep.severity)


## Start the clock on a bleep's event.
func track(bleep: Bleep) -> void:
	var target := _get_target(bleep.target_id)
	if not target:
		push_error("No EventTarget with target_id '%s' for bleep %s" % [bleep.target_id, bleep.label()])
		return
	_active.append(ActiveEvent.new(bleep))
	# handle player standing at a phone or the target already
	if get_tree().get_nodes_in_group(&"phones").any(func(phone: PlayerZone): return phone.has_player()):
		_on_phone_reached()
	if target.has_player():
		_on_target_reached(bleep.target_id)


## Are there active events?
func is_idle() -> bool:
	return _active.is_empty()


func _on_target_reached(target_id: StringName) -> void:
	for event in _active.duplicate():
		if event.bleep.target_id == target_id:
			_active.erase(event)
			resolved[event.bleep.severity] = resolved.get(event.bleep.severity, 0) + 1
			event_resolved.emit(event.bleep)


func _on_phone_reached() -> void:
	for event in _active:
		if event.heard:
			continue
		event.heard = true
		if not event.bleep.message.is_empty():
			messages.show_message(event.bleep.message, event.bleep.label())


func _get_target(target_id: StringName) -> EventTarget:
	if _targets.is_empty():
		for target: EventTarget in get_tree().get_nodes_in_group(&"event_targets"):
			_targets[target.target_id] = target
			target.player_entered.connect(_on_target_reached.bind(target.target_id))
	return _targets.get(target_id)
