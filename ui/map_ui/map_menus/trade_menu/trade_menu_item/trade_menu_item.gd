extends ItemLabel

var parent_menu: TradeMenu


func _init() -> void:
	selectable = false
	custom_minimum_size.y = 16
	for child: Control in get_children() as Array[Control]:
		child.visible = false


func update() -> void:
	for child: Control in get_children() as Array[Control]:
		child.visible = (item != null)
	if item != null:
		super()


func _on_mouse_entered() -> void:
	parent_menu.current_label = self
