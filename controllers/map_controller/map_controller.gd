## Autoload that manages and interfaces for the current [Map].
extends Control

## The currently active [Map].
var map := Map.new()
var _group_keys: Array[Key] = [
	KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0
]
var _group_modifiers: Array[Key] = [KEY_SHIFT, KEY_ALT]


func _ready() -> void:
	for key_index: int in _group_keys.size():
		var input_event := InputEventKey.new()
		input_event.keycode = _group_keys[key_index]
		var action_name: StringName = "group_%s" % (key_index + 1)
		InputMap.action_add_event(&"control_group", input_event)
		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, input_event)
	for modifier_index: int in _group_modifiers.size():
		var input_event := InputEventKey.new()
		input_event.keycode = _group_modifiers[modifier_index]
		var action_name: StringName = "group_modifier_%s" % (modifier_index + 1)
		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, input_event)


## Returns the [CanvasLayer] containing the Map's UI.
func get_ui() -> CanvasLayer:
	var path := NodePath("%s/MapUILayer" % GameController.get_root().get_path())
	return get_node(path) as CanvasLayer if has_node(path) else null


func get_control_group(event: InputEvent) -> int:
	for key_index: int in _group_keys.size():
		if event.is_action_pressed("group_%s" % (key_index + 1), true):
			var value: int = key_index + 1
			for modifier_index: int in _group_modifiers.size():
				if Input.is_key_pressed(_group_modifiers[modifier_index]):
					value += _group_keys.size() * (modifier_index + 1)
			return value
	return 0
