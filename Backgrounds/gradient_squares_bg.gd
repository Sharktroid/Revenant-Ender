extends SubViewportContainer

@export_range(0, 1) var hue_min: float = 0
@export_range(0, 1) var hue_max: float = 1
@export var duration: float = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_hue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_update_hue()



func _update_hue() -> void:
	for child in $"SubViewport/Base Color".get_children():
		var child_pos: Vector2i = (child as Polygon2D).position
		var child_offset: int = (((child_pos.x*16 + child_pos.y) as float)/32) as int
		var new_hue: float = fmod((child_offset + GenVars.get_tick_timer()) * (hue_max - hue_min) / 60 / duration,
				hue_max - hue_min) + hue_min
#		print_debug(new_hue)
		(child as Polygon2D).color.h = new_hue
