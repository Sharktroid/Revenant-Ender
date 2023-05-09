extends "res://Menus/Map Menus/base_map_menu.gd"


func _init():
	items = ["Debug", "Unit", "Status","Guide","Options","Suspend", "End"]


func _on_button_pressed(button: Button) -> void:
	match button.text:
		"Debug":
			var menu: MapMenu = preload("res://Menus/Map Menus/debug_menu.tscn").instantiate()
			menu.position = position
			GenVars.get_level_controller().get_node("UILayer").add_child(menu)
			set_active(false)
		"End":
			GenVars.get_level_controller().handle_input(true)
			close()
			GenVars.get_map().end_turn()
		_: push_error("%s is not a valid menu item" % button.text)


func close() -> void:
	super.close()
	GenVars.get_level_controller().handle_input(true)
