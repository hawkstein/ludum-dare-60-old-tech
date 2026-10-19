class_name BleepTimeline
extends Node

@export var events: Array[BleepEvent] = []

signal bleep_sent(bleep: Bleep)
signal finished

var _remaining := -1
var _stopped := false

## Start the timeline running
func start() -> void:
	_remaining = events.size()
	var elapsed := 0.0
	for event in events:
		elapsed += event.time
		get_tree().create_timer(elapsed, false).timeout.connect(_send.bind(event.bleep))


## Stop the timeline
func stop() -> void:
	_stopped = true

## Has every bleep been sent?
func is_finished() -> bool:
	return _remaining == 0


## Does any bleep in the timeline point at this target?
func has_target(target_id: StringName) -> bool:
	return events.any(func(event: BleepEvent): return event.bleep.target_id == target_id)


func total(severity: Bleep.Severity) -> int:
	return events.filter(func(event: BleepEvent): return event.bleep.severity == severity).size()


func _send(bleep: Bleep) -> void:
	if _stopped:
		return
	_remaining -= 1
	bleep_sent.emit(bleep)
	if _remaining == 0:
		finished.emit()
