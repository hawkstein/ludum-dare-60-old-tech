extends Control


func _ready() -> void:
	DataStore.get_model("Gameplay").update(false, &"show_instructions")


func _on_fancy_button_pressed() -> void:
	ScreenChanger.change_to(&"main")


func _on_menu_button_pressed() -> void:
	ScreenChanger.change_to(&"main_menu")
