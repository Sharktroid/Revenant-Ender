extends Unit
var _base_frame: int # Base frame for animation.
#var _starting_frame: int # Base frame for animation after modifiers.
#var _faction_dict: Dictionary
#var _variant_dict: Dictionary


func _ready() -> void:
	frame = _base_frame
#	_set_base_frame()


#func _set_base_frame() -> void:
	# Sets the base frame
#	var faction_offset: int = _faction_dict.get(MapController.map.get_unit_faction(faction).color, 0)
#	_base_frame = _starting_frame + faction_offset + _variant_dict.get(variant, 0)

#func change_faction(new_faction) -> void:
#	super.change_faction(new_faction)
#	_set_base_frame()


#func _update_sprite() -> void:
#	super._update_sprite()
#	frame = _base_frame
