extends Control


func _on_play_button_pressed() -> void:
	ScreenChanger.change_to(&"main")


func _on_menu_button_pressed() -> void:
	ScreenChanger.change_to(&"main_menu")
