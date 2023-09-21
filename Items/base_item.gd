class_name Item
extends Resource

enum equip_type {DISABLED, ENABLED, WEAPON, ARMOR, OTHER}

var name: String
var icon: Texture2D = PlaceholderTexture2D.new()
var max_uses: int
var current_uses: int
var price: int

var _description: String


func _init() -> void:
	if icon is PlaceholderTexture2D:
		icon.size = Vector2i(16, 16)
	current_uses = max_uses


func get_description() -> String:
	return _description
