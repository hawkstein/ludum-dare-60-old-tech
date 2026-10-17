extends Control
## Upgrade shop demo: buy scaled upgrades with currencies saved through DataStore.

const PROGRESS_KEY := &"Progress"

var progress := DataStore.register_model(PROGRESS_KEY, ProgressData.new()) as ProgressData
var upgrades: Array[UpgradeEntry] = [
	UpgradeEntry.scaled(&"move_speed", "Move speed", 5, 6.0, 1.15, {coins = 10}, 1.6),
	UpgradeEntry.scaled(&"jump", "Jump height", 3, 4.5, 0.2, {coins = 15, gems = 1}, 2.0,
			UpgradeEntry.Growth.LINEAR),
	UpgradeEntry.scaled(&"pickup_range", "Pickup range", 4, 1.0, 0.5, {gems = 2}, 1.0,
			UpgradeEntry.Growth.QUADRATIC, UpgradeEntry.Growth.LINEAR),
]

@onready var currency_label: Label = %CurrencyLabel
@onready var rows: GridContainer = %Rows

var _rows: Dictionary[StringName, Array] = {}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for entry in upgrades:
		_add_row(entry)
	%AddCoinsButton.pressed.connect(progress.earn.bind(&"coins", 25))
	%AddGemsButton.pressed.connect(progress.earn.bind(&"gems", 2))
	%ResetButton.pressed.connect(_on_reset_pressed)
	%MenuButton.pressed.connect(ScreenChanger.change_to.bind(&"main_menu"))
	progress.property_updated.connect(_refresh.unbind(1))
	_refresh()
	%AddCoinsButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		ScreenChanger.change_to(&"main_menu")
		get_viewport().set_input_as_handled()


func _add_row(entry: UpgradeEntry) -> void:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var button := FancyButton.new()
	button.pressed.connect(progress.buy.bind(entry))
	rows.add_child(label)
	rows.add_child(button)
	_rows[entry.key] = [label, button]


func _refresh() -> void:
	currency_label.text = "Coins: %d    Gems: %d" % [progress.currencies.get(&"coins", 0), progress.currencies.get(&"gems", 0)]
	for entry in upgrades:
		var level := progress.level_of(entry.key)
		var label: Label = _rows[entry.key][0]
		var button: Button = _rows[entry.key][1]
		label.text = "%s  Lv %d/%d  (%.2f)" % [entry.label, level, entry.max_level, entry.value_at(level)]
		if entry.is_maxed(level):
			button.text = "Maxed"
			button.disabled = true
		else:
			var cost := entry.cost_for_next(level)
			button.text = "Buy: " + _format_cost(cost)
			button.disabled = not progress.can_afford(cost)


func _format_cost(cost: Dictionary[StringName, int]) -> String:
	var parts: PackedStringArray = []
	for currency in cost:
		parts.append("%d %s" % [cost[currency], currency])
	return ", ".join(parts)


func _on_reset_pressed() -> void:
	DataStore.reset_model(PROGRESS_KEY)
	# reset() restores defaults without emitting property_updated.
	_refresh()
