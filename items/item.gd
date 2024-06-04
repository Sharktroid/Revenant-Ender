class_name Item
extends Resource

enum EquipType { DISABLED, ENABLED, WEAPON, ARMOR, OTHER }

var current_uses: float
var _icon: Texture2D = PlaceholderTexture2D.new()
var _max_uses: float
var _price: int
var _description: String
var _droppable: bool = true
var _usable: bool = false


func _init() -> void:
	var path: String = get_script().resource_path
	_icon = load(path.substr(0, path.rfind("/") + 1) + "icon.png") as Texture2D
	if _icon is PlaceholderTexture2D:
		(_icon as PlaceholderTexture2D).size = Vector2i(16, 16)
	current_uses = get_max_uses()


func _to_string() -> String:
	return "{name}:<Resource#{id}>".format({"name": resource_name, "id": get_instance_id()})


func get_item_name() -> String:
	return resource_name


func get_icon() -> Texture2D:
	return _icon


func get_max_uses() -> float:
	return roundf(_max_uses)


func get_price() -> float:
	return _price


func get_description() -> String:
	return _description


func is_droppable() -> bool:
	return _droppable


func is_usable() -> bool:
	return _usable


func use() -> void:
	pass
