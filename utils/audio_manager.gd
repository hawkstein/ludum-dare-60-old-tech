extends Node

var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func set_master_volume(volume:float) -> void:
	_set_bus_volume(MASTER_BUS_ID, volume)


func set_music_volume(volume:float) -> void:
	_set_bus_volume(MUSIC_BUS_ID, volume)


func set_sfx_volume(volume:float) -> void:
	_set_bus_volume(SFX_BUS_ID, volume)


func _set_bus_volume(bus_idx:int, volume:float) -> void:
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	AudioServer.set_bus_mute(bus_idx, is_zero_approx(volume))
