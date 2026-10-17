extends Node3D
## Narrative demo: intro once per run, coin count in the HUD.

@onready var messages: MessageLayer = $MessageLayer
@onready var coin_label: Label = %CoinLabel

func _ready() -> void:
	RunState.value_changed.connect(_on_run_value_changed)
	_update_coin_label()
	if not RunState.has_flag(&"narrative_intro_seen"):
		RunState.set_flag(&"narrative_intro_seen")
		messages.show_message("Collect the coins, then head for the exit.", "Guide")
		messages.show_message("Coins you pick up stay gone if you play again.", "Guide")


func _on_run_value_changed(key: StringName, _value: Variant) -> void:
	if key == &"coins":
		_update_coin_label()


func _update_coin_label() -> void:
	coin_label.text = "Coins: %d" % RunState.get_value(&"coins", 0)
