@tool

extends Control

signal close_window

@onready var content: Control = %Content
@onready var title_label: Label = %Title

@export var title:String = "Title":
	set(p_title):
		title = p_title
		if title_label != null:
			title_label.text = title

func _ready() -> void:
	title_label.text = title


func add_content(p_content:Control) -> void:
	content.add_child(p_content)


func _on_close_button_pressed() -> void:
	close_window.emit()
