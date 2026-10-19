extends Node3D

@export var max_normal_failures := 6
@export var end_message_duration := 2.5
@export var end_lead_in_duration := 1.0

@onready var player: ThirdPersonPlayer = %ThirdPersonPlayer
@onready var pager: PagerLayer = %PagerLayer
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var timeline: BleepTimeline = %BleepTimeline
@onready var tracker: EventTracker = %EventTracker
@onready var message: MessageLayer = %MessageLayer
@onready var feedback: FeedbackLayer = %FeedbackLayer

var _ended := false

func _ready() -> void:
	timeline.bleep_sent.connect(pager.send_bleep)
	timeline.bleep_sent.connect(tracker.track)
	timeline.finished.connect(_on_timeline_finished)
	tracker.event_failed.connect(_on_event_failed)
	tracker.event_resolved.connect(_on_event_resolved)
	timeline.start()


func _on_event_failed(bleep: Bleep, severity: Bleep.Severity) -> void:
	if _ended:
		return
	pager.remove_bleep(bleep)
	var normal_failures: int = tracker.failed.get(Bleep.Severity.NORMAL, 0)
	var missed := "Missed a bleep! (%d/%d)" % [normal_failures, max_normal_failures]
	if severity == Bleep.Severity.CRITICAL:
		_end(&"failure", [_closing_line("Patient lost! You didn't make it in time.", FeedbackLayer.Kind.FAILURE)])
	elif normal_failures >= max_normal_failures:
		_end(&"failure", [
			_lead_in(missed, FeedbackLayer.Kind.FAILURE),
			_closing_line("Too many bleeps went unanswered.", FeedbackLayer.Kind.FAILURE),
		])
	elif _shift_over():
		_end(&"success", [_lead_in(missed, FeedbackLayer.Kind.FAILURE), _shift_end_line()])
	else:
		feedback.show_message(missed, FeedbackLayer.Kind.FAILURE)


func _on_event_resolved(bleep: Bleep) -> void:
	if _ended:
		return
	pager.remove_bleep(bleep)
	if _shift_over():
		_end(&"success", [_lead_in("Well done", FeedbackLayer.Kind.SUCCESS), _shift_end_line()])
	else:
		feedback.show_now("Well done", FeedbackLayer.Kind.SUCCESS)


func _on_timeline_finished() -> void:
	if _shift_over():
		_end(&"success", [_shift_end_line()])


func _shift_over() -> bool:
	return timeline.is_finished() and tracker.is_idle()


func _lead_in(text: String, kind: FeedbackLayer.Kind) -> Dictionary:
	return feedback.entry(text, kind, end_lead_in_duration)


func _closing_line(text: String, kind: FeedbackLayer.Kind) -> Dictionary:
	return feedback.entry(text, kind, end_message_duration)


func _shift_end_line() -> Dictionary:
	return _closing_line("That's the end of your shift.", FeedbackLayer.Kind.SUCCESS)


## Play the closing lines, then fade to the end screen. Only the first call counts.
func _end(screen: StringName, lines: Array[Dictionary] = []) -> void:
	if _ended:
		return
	_ended = true
	_freeze_shift()
	_save_score()
	message.clear()
	if not lines.is_empty():
		feedback.play_sequence(lines)
		await feedback.queue_finished
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
