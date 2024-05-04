extends "res://ui/map_ui/map_menus/unit_menu/unit_menu.gd"


func update() -> void:
	pass


func _wait() -> void:
	(caller as CantoController).remove_tiles()
	super()
