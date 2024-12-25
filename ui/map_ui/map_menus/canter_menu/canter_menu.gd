extends UnitMenu


static func instantiate(
	new_offset: Vector2, parent: MapMenu, unit: Unit
) -> UnitMenu:
	const PACKED_SCENE = preload("res://ui/map_ui/map_menus/canter_menu/canter_menu.tscn")
	return _base_instantiate(PACKED_SCENE, new_offset, parent, unit)


func _update() -> void:
	pass


func _wait() -> void:
	MapController.map.state = Map.States.SELECTING
	super()
