class_name FancyButton
extends Button
## Button that grows and plays a sound when hovered or focused.

@export var hover_sound: AudioStream = preload("res://utils/ui/over2.wav")
@export var press_sound: AudioStream = preload("res://utils/ui/pressed.wav")
@export var focus_scale := 1.1

var _stream := AudioStreamPlayer.new()
var _tween: Tween

func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	_stream.bus = &"SFX"
	add_child(_stream, false, INTERNAL_MODE_FRONT)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			# Hover takes focus so the mouse and keyboard never highlight different buttons.
			if not disabled and focus_mode != FOCUS_NONE:
				grab_focus()
		NOTIFICATION_FOCUS_ENTER:
			_tween_scale(Vector2.ONE * focus_scale, 0.3)
			_play(hover_sound)
		NOTIFICATION_FOCUS_EXIT:
			_tween_scale(Vector2.ONE, 0.2)


func _pressed() -> void:
	_play(press_sound)


func _tween_scale(target: Vector2, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", target, duration)


func _play(audio_stream: AudioStream) -> void:
	if audio_stream:
		_stream.stream = audio_stream
		_stream.play()
