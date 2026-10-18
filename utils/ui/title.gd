@tool
class_name Title
extends CenterContainer

@export var text := "Title":
	set(value):
		text = value
		if is_node_ready():
			_update_text()

var _tween: Tween


func _ready() -> void:
	_update_text()
	if not Engine.is_editor_hint():
		play_intro()


func play_intro() -> void:
	var background: Label = %BackgroundLabel
	var heartbeat: Control = %Heartbeat
	var panel: PanelContainer = %PanelContainer
	var top_label: Label = %TopLabel

	for node: Control in [background, heartbeat, panel, top_label]:
		node.modulate.a = 0.0

	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	background.pivot_offset_ratio = Vector2(0.5, 0.5)
	_tween.tween_property(background, "modulate:a", 1.0, 0.6)
	_tween.tween_property(background, "scale", Vector2.ONE, 0.6).from(Vector2.ONE * 1.5)

	_tween.tween_property(heartbeat, "modulate:a", 1.0, 0.2).set_delay(0.3)
	
	panel.pivot_offset_ratio = Vector2(0.5, 0.5)
	_tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_delay(0.4)
	_tween.tween_property(panel, "scale", Vector2.ONE, 0.4) \
			.from(Vector2.ONE * 0.8).set_delay(0.4)
	
	top_label.pivot_offset_ratio = Vector2(0.5, 0.5)
	_tween.tween_property(top_label, "modulate:a", 1.0, 0.4).set_delay(0.6)
	_tween.tween_property(top_label, "scale", Vector2.ONE, 0.4) \
			.from(Vector2.ONE * 1.3).set_delay(0.6)


func _update_text() -> void:
	%BackgroundLabel.text = text
	%Label.text = text
	%TopLabel.text = text
