extends Area3D
## Offers to replay the level or return to the main menu.

@export var choice_screen: ChoiceScreen

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonPlayer:
		var coins: int = RunState.get_value(&"coins", 0)
		choice_screen.present("Level complete", "You collected %d coins." % coins, [
			{label = "Play again", action = get_tree().reload_current_scene},
			{label = "Main menu", action = &"main_menu"},
		])
