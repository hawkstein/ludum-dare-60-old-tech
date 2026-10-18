class_name PagerLayer
extends CanvasLayer

signal bleep_received(bleep: Bleep)

@export var slide_time := 0.3
@export var visible_time := 4.0
@export var empty_text := "NO BLEEPS"

@onready var panel: Control = %Panel
@onready var counter_label: Label = %CounterLabel
@onready var bleep_label: Label = %BleepLabel
@onready var sfx_player: AudioStreamPlayer = %SfxPlayer

var _bleeps: Array[Bleep] = []
var _index := 0
var _open := false
var _tween: Tween
var _hidden := 0.0
var _time_left := 0.0

func _ready() -> void:
	# Move offscreen to start
	panel.offset_transform_enabled = true
	_set_slide(1.0)
	hide()
	_refresh()


func _process(delta: float) -> void:
	if not _open:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		close()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"Pager"):
		return
	if _open and not _bleeps.is_empty():
		_index = posmod(_index - 1, _bleeps.size())
	elif not _open:
		_index = maxi(_bleeps.size() - 1, 0)
	show_pager()
	get_viewport().set_input_as_handled()


## Add a bleep onto the queue and pop the pager up on it.
func send_bleep(bleep: Bleep) -> void:
	_bleeps.append(bleep)
	_index = _bleeps.size() - 1
	if sfx_player.stream:
		sfx_player.play()
	bleep_received.emit(bleep)
	show_pager()


## Remove a bleep once its event is resolved or failed.
func remove_bleep(bleep: Bleep) -> void:
	var idx := _bleeps.find(bleep)
	if idx == -1:
		return
	_bleeps.remove_at(idx)
	if idx < _index:
		_index -= 1
	_index = clampi(_index, 0, maxi(_bleeps.size() - 1, 0))
	_refresh()

## is the pager UI open?
func is_open() -> bool:
	return _open


## Slide the pager up, or keep it up for another visible_time.
func show_pager() -> void:
	_time_left = visible_time
	if not _open:
		_open = true
		show()
		_slide(0.0)
	_refresh()


## Slide the pager down.
func close() -> void:
	if not _open:
		return
	_open = false
	_slide(1.0).tween_callback(hide)


func _refresh() -> void:
	var empty := _bleeps.is_empty()
	bleep_label.text = empty_text if empty else _bleeps[_index].label()
	counter_label.text = "" if empty else "%d/%d" % [_index + 1, _bleeps.size()]


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
