extends "res://ui/map_ui/options_menu/options_menu.gd"

func _get_options() -> Array[ConfigOption]:
	return DebugConfig.get_options()


func _add_icon(_option: ConfigOption) -> void:
	pass
