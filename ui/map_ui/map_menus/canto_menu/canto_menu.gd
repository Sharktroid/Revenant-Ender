extends "res://ui/map_ui/map_menus/unit_menu/unit_menu.gd"


func update() -> void:
	pass


func _wait() -> void:
	const CANTO_CONTROLLER = preload("res://controllers/map_controller/canto_controller.gd")
	(caller as CANTO_CONTROLLER).remove_tiles()
	super()
