extends Node
## Node Name: DataStore
## This is an autoloader for saving game config and state to the users machine

const SAVE_PATH := "user://{0}_data.json"

var data:Dictionary[StringName, DataModel] = {
	"Audio" : AudioData.new(),
	"Input" : InputData.new(),
	"Gameplay" : GameplayData.new(),
}

var debounce_timers:Dictionary[StringName, Timer] = {}

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	for key in data:
		_setup_model(key)

## Get a registered model by key.
func get_model(key:StringName) -> DataModel:
	return data[key]


## Add a model at runtime. Returns the existing model if the key is already registered.
func register_model(key:StringName, model:DataModel) -> DataModel:
	if key in data:
		return data[key]
	data[key] = model
	# Before _ready (e.g. a scene run directly), _ready sets up every model including this one.
	if is_node_ready():
		_setup_model(key)
	return model


## Restore a model's defaults and save immediately.
func reset_model(key:StringName) -> void:
	data[key].reset()
	save_data(key)


## Save every registered model to disk now.
func save_game_data() -> void:
	for key in data:
		save_data(key)


## Save one model to user://{key}_data.json now.
func save_data(key:StringName) -> void:
	var data_dict = data[key].to_dict()
	var json_string := JSON.stringify(data_dict)
	var model_path = SAVE_PATH.format([key])
	var file_access := FileAccess.open(model_path, FileAccess.WRITE)
	
	if not file_access:
		printerr(FileAccess.get_open_error())
		return
	
	file_access.store_line(json_string)
	file_access.close()

## Save a model 0.5s after its last change.
func save_data_debounced(_property_name:StringName, key: StringName):
	if not key in debounce_timers:
		_create_debounce_timer(key)
	var timer = debounce_timers[key]
	timer.stop()
	timer.start()

func _create_debounce_timer(key: StringName):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.ignore_time_scale = true
	timer.one_shot = true
	timer.timeout.connect(save_data.bind(key))
	debounce_timers[key] = timer

func _setup_model(key:StringName) -> void:
	_load_model(key)
	data[key].apply()
	data[key].property_updated.connect(save_data_debounced.bind(key))

func _load_model(key:StringName) -> void:
	var model_path = SAVE_PATH.format([key])
	if not FileAccess.file_exists(model_path):
		return
	
	var file_access := FileAccess.open(model_path, FileAccess.READ)
	var json_string := file_access.get_line()
	file_access.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		printerr(json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	data[key].from_dict(json.data)
