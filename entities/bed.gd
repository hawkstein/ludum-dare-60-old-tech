class_name Bed
extends EventTarget

const SKIN_TONES: Array[Color] = [
	Color("ffcdc4ff"),
	Color("f9a58fff"),
	Color("f6d6e2ff"),
	Color("#e0ac69"),
	Color("f6cfaaff"),
	Color("a45736ff"),
	Color("9a4a2aff"),
	Color("#5c3a1e"),
	Color("351e15ff"),
]

@onready var patient: Node3D = %Patient
@onready var head: MeshInstance3D = %Head

func _ready() -> void:
	super()
	randomise_skin_tone()

func randomise_skin_tone() -> void:
	var material := head.get_surface_override_material(0).duplicate() as StandardMaterial3D
	material.albedo_color = SKIN_TONES.pick_random()
	head.set_surface_override_material(0, material)


## Hide the patient so the bed looks empty.
func remove_patient() -> void:
	patient.hide()
