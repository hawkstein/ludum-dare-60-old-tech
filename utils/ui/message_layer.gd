class_name MessageLayer
extends CanvasLayer
## Queued on-screen messages with an optional speaker name.

signal message_shown(text: String, speaker: String)
signal queue_finished

## Which sound a message plays as it appears.
enum Sound { DEFAULT, SUCCESS, FAILURE, NONE }

@export var default_duration := 4.0
@export var fade_time := 0.25
@export var default_sound: AudioStream
@export var success_sound: AudioStream
@export var failure_sound: AudioStream

@onready var panel: Control = %Panel
@onready var speaker_label: Label = %SpeakerLabel
@onready var message_label: Label = %MessageLabel
@onready var sfx_player: AudioStreamPlayer = %SfxPlayer

var _queue: Array[Dictionary] = []
var _running := false
var _run_id := 0
var _tween: Tween

func _ready() -> void:
	panel.modulate.a = 0.0
	panel.hide()


## Queue a message
func show_message(text: String, speaker := "", duration := -1.0, sound := Sound.DEFAULT) -> void:
	_queue.append(entry(text, speaker, duration, sound))
	if not _running:
		_run_queue()


## Build a queue entry
func entry(text: String, speaker := "", duration := -1.0, sound := Sound.DEFAULT) -> Dictionary:
	return {text = text, speaker = speaker, duration = duration if duration >= 0.0 else default_duration, sound = sound}


## Drop all queued messages and fade out the current one
func clear() -> void:
	_queue.clear()
	_run_id += 1
	_running = false
	_fade(0.0).tween_callback(panel.hide)


func _run_queue() -> void:
	_running = true
	# clear() bumps _run_id, so a stale loop stops at its next await.
	var run := _run_id
	while not _queue.is_empty():
		var message: Dictionary = _queue.pop_front()
		speaker_label.text = message.speaker
		speaker_label.visible = not message.speaker.is_empty()
		message_label.text = message.text
		panel.show()
		var stream := _stream_for(message.sound)
		if stream:
			sfx_player.stream = stream
			sfx_player.play()
		message_shown.emit(message.text, message.speaker)

		await _fade(1.0).finished
		if run != _run_id:
			return
		await get_tree().create_timer(message.duration, false).timeout
		if run != _run_id:
			return
		await _fade(0.0).finished
		if run != _run_id:
			return

	panel.hide()
	_running = false
	queue_finished.emit()


func _stream_for(sound: Sound) -> AudioStream:
	match sound:
		Sound.SUCCESS:
			return success_sound
		Sound.FAILURE:
			return failure_sound
		Sound.NONE:
			return null
	return default_sound


func _fade(alpha: float) -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(panel, "modulate:a", alpha, fade_time)
	return _tween
