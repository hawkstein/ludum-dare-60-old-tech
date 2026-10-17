class_name DataModel
extends Resource

signal property_updated(property_name)

func to_dict() -> Dictionary:
	var props = get_property_list()
	var dict: Dictionary = { }
	
	for p in props:
		if p.usage == PROPERTY_USAGE_SCRIPT_VARIABLE and not p.name == "property_updated":
			dict[p.name] = get(p.name)
	
	return dict

func from_dict(dict: Dictionary) -> void:
	for p in get_property_list():
		if not dict.has(p.name):
			continue
		var value = dict[p.name]
		match p.type:
			TYPE_ARRAY:
				(get(p.name) as Array).assign(value)
			TYPE_DICTIONARY:
				(get(p.name) as Dictionary).assign(value)
			TYPE_INT:
				set(p.name, int(value))
			_:
				set(p.name, value)


func update(value:Variant, property_name:StringName) -> void:
	#print("Update {0} to {1}".format([property_name, value]))
	set(property_name, value)
	property_updated.emit(property_name)


## Override in models that drive engine state.
func apply() -> void:
	pass


func update_by(amount: Variant, property_name: StringName) -> void:
	update(get(property_name) + amount, property_name)


func reset() -> void:
	from_dict(get_script().new().to_dict())
	apply()


class PropertyMeta:
	var label:String
	func _init(p_label:String):
		label = p_label

class SliderMeta extends PropertyMeta:
	var min_value:float
	var max_value:float
	var step:float
	func _init(p_label:String, p_min = 0.0, p_max = 1.0, p_step = 0.05):
		super._init(p_label)
		min_value = p_min
		max_value = p_max
		step = p_step
		
