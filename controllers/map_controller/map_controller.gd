extends Control

var map := Map.new()


func _ready() -> void:
	if Utilities.is_running_project():
		(get_ui().get_node("FPS Display") as HBoxContainer).visible = Utilities.get_debug_value(
			Utilities.DebugConfigKeys.SHOW_FPS
		)
	else:
		queue_free()
		set_physics_process(false)


func _process(delta: float) -> void:
	(get_ui().get_node("%Average Process Frame Label") as Label).text = str(
		Engine.get_frames_per_second()
	)
	(get_ui().get_node("%Immediate Process Frame Label") as Label).text = str(roundi(1 / delta))


func _physics_process(delta: float) -> void:
	(get_ui().get_node("%Physic Frame Label") as Label).text = str(roundi(1 / delta))


func get_ui() -> CanvasLayer:
	var path := NodePath("%s/MapUILayer" % GameController.get_root().get_path())
	return get_node(path) as CanvasLayer if has_node(path) else null


func get_map_camera() -> MapCamera:
	var path: String = NodePath("%s/MapCamera" % map.get_path())
	return (get_node(path) as MapCamera) if has_node(path) else MapCamera.new()
