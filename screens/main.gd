extends Node3D

@export var max_normal_failures := 6
@export var end_speaker := "Medical Director"
@export var end_message_duration := 2.5

const JOY_BUTTON_NAMES := {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "LS",
	JOY_BUTTON_RIGHT_STICK: "RS",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-Pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
	JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
}

@onready var player: ThirdPersonPlayer = %ThirdPersonPlayer
@onready var pager: PagerLayer = %PagerLayer
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var timeline: BleepTimeline = %BleepTimeline
@onready var tracker: EventTracker = %EventTracker
@onready var message: MessageLayer = %MessageLayer
@onready var alert: PanelContainer = %PagerAlertPanel
@onready var alert_label: Label = %PagerAlertLabel

var _ended := false
var _alert_tween: Tween
var _using_gamepad := false

func _ready() -> void:
	pager.open_changed.connect(_on_pager_open_changed)
	timeline.bleep_sent.connect(pager.send_bleep)
	timeline.bleep_sent.connect(tracker.track)
	timeline.bleep_sent.connect(_display_alert)
	timeline.finished.connect(_check_success)
	tracker.event_failed.connect(_on_event_failed)
	tracker.event_resolved.connect(_on_event_resolved)
	alert.hide()
	timeline.start()


func _on_pager_open_changed(open: bool) -> void:
	player.input_enabled = not open
	pause_menu.resume_mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED
	if open:
		_hide_alert()


func _on_event_failed(_bleep: Bleep, severity: Bleep.Severity) -> void:
	var normal_failures: int = tracker.failed.get(Bleep.Severity.NORMAL, 0)
	if severity == Bleep.Severity.CRITICAL:
		_end(&"failure", "Patient lost! You didn't make it in time.", MessageLayer.Sound.FAILURE)
	elif normal_failures >= max_normal_failures:
		_end(&"failure", "Too many bleeps went unanswered.", MessageLayer.Sound.FAILURE)
	else:
		message.show_message("Missed a bleep! (%d/%d)" % [normal_failures, max_normal_failures], end_speaker, -1.0, MessageLayer.Sound.FAILURE)
		_check_success()


func _on_event_resolved(_bleep: Bleep) -> void:
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
	# Close first: it emits open_changed, which would turn player input back on.
	pager.close()
	pager.set_process_input(false)
	player.input_enabled = false


func _save_score() -> void:
	for severity in Bleep.Severity.values():
		RunState.set_value(&"score_%d" % severity, {
			resolved = tracker.resolved.get(severity, 0),
			failed = tracker.failed.get(severity, 0),
			total = timeline.total(severity),
		})


func _display_alert(_bleep: Bleep) -> void:
	if pager.is_open():
		return
	if not alert.visible:
		alert.modulate.a = 0.0
		alert.offset_transform_position.y = 0.0
		alert.show()
		alert_label.text = "New Bleep! (Press %s)" % _pager_binding_text()
	_tween_alert(1.0, -100.0)


func _hide_alert() -> void:
	if not alert.visible:
		return
	_tween_alert(0.0, 0.0).chain().tween_callback(alert.hide)


func _tween_alert(alpha: float, y: float) -> Tween:
	if _alert_tween:
		_alert_tween.kill()
	_alert_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	_alert_tween.tween_property(alert, "modulate:a", alpha, 0.5)
	_alert_tween.tween_property(alert, "offset_transform_position:y", y, 0.5)
	return _alert_tween
		

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		_using_gamepad = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		_using_gamepad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		_using_gamepad = false


func _pager_binding_text() -> String:
	var fallback := ""
	for event in InputMap.action_get_events(&"Pager"):
		var text := ""
		if event is InputEventKey:
			text = OS.get_keycode_string((event as InputEventKey).keycode)
		elif event is InputEventJoypadButton:
			var button := (event as InputEventJoypadButton).button_index
			text = JOY_BUTTON_NAMES.get(button, "Button %d" % button)
		if text.is_empty():
			continue
		if (event is InputEventJoypadButton) == _using_gamepad:
			return text
		if fallback.is_empty():
			fallback = text
	return fallback
