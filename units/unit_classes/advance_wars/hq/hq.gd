#tool
extends "res://Unit Classes/city.gd"


func _init():
	unit_class = "HQ"


func _ready() -> void:
	match variant:
		"Orange Star":  _starting_frame = 0
		"Blue Moon":    _starting_frame = 1
		"Yellow Comet": _starting_frame = 2
		"Green Earth":  _starting_frame = 3
		"Black Hole":   _starting_frame = 4
	super._ready()
