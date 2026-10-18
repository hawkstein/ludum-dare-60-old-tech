extends Node3D

@export var max_normal_failures := 6
@export var end_speaker := "Medical Director"
@export var end_message_duration := 2.5

@onready var player: ThirdPersonPlayer = %ThirdPersonPlayer
@onready var pager: PagerLayer = %PagerLayer
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var timeline: BleepTimeline = %BleepTimeline
@onready var tracker: EventTracker = %EventTracker
@onready var message: MessageLayer = %MessageLayer

var _ended := false

func _ready() -> void:
	timeline.bleep_sent.connect(pager.send_bleep)
	timeline.bleep_sent.connect(tracker.track)
	timeline.finished.connect(_check_success)
	tracker.event_failed.connect(_on_event_failed)
	tracker.event_resolved.connect(_on_event_resolved)
	timeline.start()


func _on_event_failed(bleep: Bleep, severity: Bleep.Severity) -> void:
	pager.remove_bleep(bleep)
	var normal_failures: int = tracker.failed.get(Bleep.Severity.NORMAL, 0)
	if severity == Bleep.Severity.CRITICAL:
		_end(&"failure", "Patient lost! You didn't make it in time.", MessageLayer.Sound.FAILURE)
	elif normal_failures >= max_normal_failures:
		_end(&"failure", "Too many bleeps went unanswered.", MessageLayer.Sound.FAILURE)
	else:
		message.show_message("Missed a bleep! (%d/%d)" % [normal_failures, max_normal_failures], end_speaker, -1.0, MessageLayer.Sound.FAILURE)
		_check_success()


func _on_event_resolved(bleep: Bleep) -> void:
	pager.remove_bleep(bleep)
	message.show_message("Well done", end_speaker, -1.0, MessageLayer.Sound.SUCCESS)
	_check_success()


func _check_success() -> void:
	if timeline.is_finished() and tracker.is_idle():
		_end(&"success", "That's the end of your shift.", MessageLayer.Sound.SUCCESS)


## Play the closing line, then fade to the end screen. Only the first call counts.
func _end(screen: StringName, text := "", sound := MessageLayer.Sound.DEFAULT) -> void:
	if _ended:
		return
	_ended = true
	_freeze_shift()
	_save_score()
	if not text.is_empty():
		message.clear()
		message.show_message(text, end_speaker, end_message_duration, sound)
		await message.queue_finished
	ScreenChanger.change_to(screen)


func _freeze_shift() -> void:
	timeline.stop()
	tracker.set_process(false)
	pager.close()
	pager.set_process(false)
	pager.set_process_input(false)
	player.input_enabled = false


func _save_score() -> void:
	for severity in Bleep.Severity.values():
		RunState.set_value(&"score_%d" % severity, {
			resolved = tracker.resolved.get(severity, 0),
			failed = tracker.failed.get(severity, 0),
			total = timeline.total(severity),
		})
