class_name FeedbackLayer
extends CanvasLayer
## Resolve/fail feedback from the Medical Director.

signal queue_finished

enum Kind { SUCCESS, FAILURE }
enum Corner { TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

@export var default_duration := 4.0
@export var fade_time := 0.25
@export var slide_time := 0.5
@export var slide_distance := 300.0
@export var slide_trans: Tween.TransitionType = Tween.TRANS_BACK
@export var director_pop_time := 0.35
@export var director_pop_delay := 0.3
## How far below the authored rest position the director hides.
@export var director_drop := 170.0
# Cast prevents Godot parse error on enum-typed array literals - investigate more at some point
@export var corners: Array[Corner] = [Corner.BOTTOM_RIGHT as Corner]
@export var success_sound: AudioStream
@export var failure_sound: AudioStream
@export var success_animation := &"success"
@export var failure_animation := &"idle"

@onready var panel: Control = %Panel
@onready var success_background: Control = %SuccessBackground
@onready var failure_background: Control = %FailureBackground
@onready var message_label: Label = %MessageLabel
@onready var sfx_player: AudioStreamPlayer = %SfxPlayer
@onready var director: Control = %Director
@onready var director_animation: AnimationPlayer = %MedicalDirector.get_node(^"AnimationPlayer")

var _queue: Array[Dictionary] = []
var _running := false
var _run_id := 0
var _tween: Tween
var _director_shown_y: float

func _ready() -> void:
	_director_shown_y = director.position.y
	panel.modulate.a = 0.0
	panel.hide()


## Queue a message
func show_message(text: String, kind: Kind, duration := -1.0) -> void:
	_queue.append(entry(text, kind, duration))
	if not _running:
		_run_queue()


## Replace the current message immediately
func show_now(text: String, kind: Kind, duration := -1.0) -> void:
	_queue.push_front(entry(text, kind, duration))
	_restart()


## immediately play these entries in order
func play_sequence(messages: Array[Dictionary]) -> void:
	_queue.assign(messages)
	_restart()


## Build a queue entry
func entry(text: String, kind: Kind, duration := -1.0) -> Dictionary:
	return {text = text, kind = kind, duration = duration if duration >= 0.0 else default_duration}


func _restart() -> void:
	# Bumping _run_id stops the running loop at its next await.
	_run_id += 1
	_run_queue()


func _run_queue() -> void:
	_running = true
	var run := _run_id
	while not _queue.is_empty():
		var message: Dictionary = _queue.pop_front()
		message_label.text = message.text
		success_background.visible = message.kind == Kind.SUCCESS
		failure_background.visible = message.kind == Kind.FAILURE
		var side := _place(corners.pick_random())
		panel.show()
		sfx_player.stream = success_sound if message.kind == Kind.SUCCESS else failure_sound
		sfx_player.play()
		_play_director(success_animation if message.kind == Kind.SUCCESS else failure_animation)

		
		offset.x = side * slide_distance
		panel.modulate.a = 0.0
		director.position.y = _director_shown_y + director_drop
		await _animate(0.0, 1.0, Tween.EASE_OUT).finished
		if run != _run_id:
			return
		await get_tree().create_timer(message.duration, false).timeout
		if run != _run_id:
			return
		await _animate(side * slide_distance, 0.0, Tween.EASE_IN).finished
		if run != _run_id:
			return

	panel.hide()
	_running = false
	queue_finished.emit()


## Returns which side it slides from: -1 left, 1 right.
func _place(corner: Corner) -> float:
	var left := corner == Corner.TOP_LEFT
	var top := corner != Corner.BOTTOM_RIGHT
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if left else Control.SIZE_SHRINK_END
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if top else Control.SIZE_SHRINK_END
	return -1.0 if left else 1.0


func _play_director(animation: StringName) -> void:
	# Back to the rest pose first, or tracks the new animation doesn't key stay where the last one left them.
	director_animation.play(&"RESET")
	director_animation.advance(0.0)
	director_animation.play(animation)


func _animate(x: float, alpha: float, easing: Tween.EaseType) -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "offset:x", x, slide_time).set_trans(slide_trans).set_ease(easing)
	_tween.tween_property(panel, "modulate:a", alpha, fade_time)
	# Pops up once the panel has mostly arrived, ducks straight away on the way out.
	var showing := alpha > 0.0
	var director_y := _director_shown_y if showing else _director_shown_y + director_drop
	_tween.tween_property(director, "position:y", director_y, director_pop_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(easing).set_delay(director_pop_delay if showing else 0.0)
	return _tween
