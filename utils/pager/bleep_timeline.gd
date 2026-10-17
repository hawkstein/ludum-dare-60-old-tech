class_name BleepTimeline
extends Node

@export var events: Array[BleepEvent] = []

signal bleep_sent(bleep: Bleep)

func start() -> void:
	for event in events:
		get_tree().create_timer(event.time, false).timeout.connect(bleep_sent.emit.bind(event.bleep))
