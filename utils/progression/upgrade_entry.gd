class_name UpgradeEntry
extends RefCounted
## An upgrade with a value and a cost that scale per level. Level 0 is the base, before any purchase.

enum Growth { LINEAR, QUADRATIC, EXPONENTIAL }

var key: StringName
var label: String
var max_level: int
var base_value: float
var value_growth: float
var value_mode: Growth
var base_cost: Dictionary[StringName, int]
var cost_growth: float
var cost_mode: Growth

## Build an entry. Growth is the per-level factor for the chosen mode.
static func scaled(p_key: StringName, p_label: String, p_max_level: int,
		p_base_value: float, p_value_growth: float,
		p_base_cost: Dictionary, p_cost_growth: float,
		p_value_mode := Growth.EXPONENTIAL, p_cost_mode := Growth.EXPONENTIAL) -> UpgradeEntry:
	var entry := UpgradeEntry.new()
	entry.key = p_key
	entry.label = p_label
	entry.max_level = p_max_level
	entry.base_value = p_base_value
	entry.value_growth = p_value_growth
	entry.value_mode = p_value_mode
	entry.base_cost.assign(p_base_cost)
	entry.cost_growth = p_cost_growth
	entry.cost_mode = p_cost_mode
	return entry


## Scale factor at a tier; always 1.0 at tier 0.
static func multiplier(tier: int, growth: float, mode: Growth) -> float:
	match mode:
		Growth.LINEAR:
			return 1.0 + growth * tier
		Growth.QUADRATIC:
			return 1.0 + growth * tier * tier
		_:
			return pow(growth, tier)


## The upgrade's value at a level.
func value_at(level: int) -> float:
	return base_value * multiplier(level, value_growth, value_mode)


## Cost of buying the level after this one, rounded up.
func cost_for_next(level: int) -> Dictionary[StringName, int]:
	var cost: Dictionary[StringName, int] = {}
	var scale := multiplier(level, cost_growth, cost_mode)
	for currency in base_cost:
		cost[currency] = ceili(base_cost[currency] * scale)
	return cost


## Whether no more levels can be bought.
func is_maxed(level: int) -> bool:
	return level >= max_level
