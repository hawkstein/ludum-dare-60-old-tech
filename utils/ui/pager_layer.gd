class_name PagerLayer
extends CanvasLayer

signal open_changed(open: bool)
signal bleep_received(bleep: Bleep)

@export var slide_time := 0.2
@export var empty_text := "NO BLEEPS"

@onready var panel: Control = %Panel
@onready var counter_label: Label = %CounterLabel
@onready var bleep_label: Label = %BleepLabel
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var delete_button: Button = %DeleteButton
@onready var close_button: Button = %CloseButton
@onready var sfx_player: AudioStreamPlayer = %SfxPlayer

var _bleeps: Array[Bleep] = []
var _index := 0
var _open := false
var _tween: Tween
var _hidden := 0.0

func _ready() -> void:
	prev_button.pressed.connect(_step.bind(-1))
	next_button.pressed.connect(_step.bind(1))
	delete_button.pressed.connect(delete_current)
	close_button.pressed.connect(close)
	# Move offscreen to start
	panel.offset_transform_enabled = true
	_set_slide(1.0)
	hide()
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Pager"):
		toggle()
	elif event.is_action_pressed(&"ui_cancel") and _open:
		close()
	else:
		return
	get_viewport().set_input_as_handled()


## Add a bleep onto the queue.
func send_bleep(bleep: Bleep) -> void:
	_bleeps.append(bleep)
	if sfx_player.stream:
		sfx_player.play()
	bleep_received.emit(bleep)
	_refresh()


## Remove the current bleep.
func delete_current() -> void:
	if _bleeps.is_empty():
		return
	_bleeps.remove_at(_index)
	_index = clampi(_index, 0, maxi(_bleeps.size() - 1, 0))
	_refresh()

## is the pager UI open?
func is_open() -> bool:
	return _open

## Toggle UI display
func toggle() -> void:
	if _open:
		close()
	else:
		open()


## Slide the pager up, showing the newest bleep.
func open() -> void:
	if _open:
		return
	_open = true
	_index = maxi(_bleeps.size() - 1, 0)
	_refresh()
	show()
	# Emit before freeing the mouse so the pause menu knows the release is expected.
	open_changed.emit(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	close_button.grab_focus()
	_slide(0.0)


## Slide the pager down.
func close() -> void:
	if not _open:
		return
	_open = false
	get_viewport().gui_release_focus()
	open_changed.emit(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_slide(1.0).tween_callback(hide)


func _step(direction: int) -> void:
	_index = clampi(_index + direction, 0, maxi(_bleeps.size() - 1, 0))
	_refresh()


func _refresh() -> void:
	var empty := _bleeps.is_empty()
	bleep_label.text = empty_text if empty else _bleeps[_index].label()
	counter_label.text = "" if empty else "%d/%d" % [_index + 1, _bleeps.size()]
	prev_button.disabled = empty or _index == 0
	next_button.disabled = empty or _index == _bleeps.size() - 1
	delete_button.disabled = empty

	# Avoid leaving gamepad focus stranded on a disabled button.
	var focused := get_viewport().gui_get_focus_owner() as Button
	if _open and focused and focused.disabled:
		close_button.grab_focus()


func _slide(hidden: float) -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_slide, _hidden, hidden, slide_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return _tween

func _set_slide(hidden: float) -> void:
	_hidden = hidden
	panel.offset_transform_position_ratio.y = hidden
	panel.offset_transform_position.y = hidden * _bottom_margin()


func _bottom_margin() -> float:
	var margin := panel.get_parent() as MarginContainer
	return margin.get_theme_constant(&"margin_bottom") if margin else 0
