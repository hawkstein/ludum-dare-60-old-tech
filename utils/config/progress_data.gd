class_name ProgressData
extends DataModel
## Saved progression: currencies, upgrade levels and best run. Register it with DataStore.register_model.

var currencies: Dictionary[StringName, int] = {}
var levels: Dictionary[StringName, int] = {}
var best_run := 0

func _init() -> void:
	set_meta("title", "Progress")


## Add an amount of a currency.
func earn(currency: StringName, amount: int) -> void:
	currencies[currency] = currencies.get(currency, 0) + amount
	update(currencies, &"currencies")


## Whether every currency in the cost can be paid.
func can_afford(cost: Dictionary) -> bool:
	for currency in cost:
		if currencies.get(currency, 0) < cost[currency]:
			return false
	return true


## Pay a cost if affordable. Returns whether it was paid.
func pay(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for currency in cost:
		currencies[currency] = currencies.get(currency, 0) - cost[currency]
	update(currencies, &"currencies")
	return true


## Current level of an upgrade, 0 if never bought.
func level_of(key: StringName) -> int:
	return levels.get(key, 0)


## The entry's value at its current level.
func value_of(entry: UpgradeEntry) -> float:
	return entry.value_at(level_of(entry.key))


## Buy the entry's next level. Returns false if maxed or unaffordable.
func buy(entry: UpgradeEntry) -> bool:
	var level := level_of(entry.key)
	if entry.is_maxed(level) or not pay(entry.cost_for_next(level)):
		return false
	levels[entry.key] = level + 1
	update(levels, &"levels")
	return true


## Keep the score if it beats best_run. Returns whether it did.
func record_run(score: int) -> bool:
	if score <= best_run:
		return false
	update(score, &"best_run")
	return true
