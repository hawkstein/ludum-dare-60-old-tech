extends Node3D

@onready var player: ThirdPersonPlayer = %ThirdPersonPlayer
@onready var pager: PagerLayer = %PagerLayer
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var timeline: BleepTimeline = %BleepTimeline

func _ready() -> void:
	pager.open_changed.connect(_on_pager_open_changed)
	timeline.bleep_sent.connect(pager.send_bleep)
	timeline.start()


func _on_pager_open_changed(open: bool) -> void:
	player.input_enabled = not open
	pause_menu.resume_mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED
