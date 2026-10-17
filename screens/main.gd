extends Node3D

@onready var player: ThirdPersonPlayer = %ThirdPersonPlayer
@onready var pager: PagerLayer = %PagerLayer
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var timeline: BleepTimeline = %BleepTimeline
@onready var tracker: EventTracker = %EventTracker
@onready var message: MessageLayer = %MessageLayer

func _ready() -> void:
	pager.open_changed.connect(_on_pager_open_changed)
	timeline.bleep_sent.connect(pager.send_bleep)
	timeline.bleep_sent.connect(tracker.track)
	tracker.event_failed.connect(_handle_event_fail)
	tracker.event_resolved.connect(_handle_event_resolved)
	timeline.start()


func _on_pager_open_changed(open: bool) -> void:
	player.input_enabled = not open
	pause_menu.resume_mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED


func _handle_event_fail(_bleep: Bleep, _severity: Bleep.Severity) -> void:
	message.show_message("Event failed")


func _handle_event_resolved(_bleep:Bleep) -> void:
	message.show_message("event resolved successfully")
