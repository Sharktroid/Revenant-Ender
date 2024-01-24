extends ItemLabel

var parent_menu: TradeMenu


func _init() -> void:
	selectable = false
	custom_minimum_size.y = 16
	for child: Node in get_children():
		child.visible = false


func update() -> void:
	for child: Node in get_children():
		child.visible = (item != null)
	if item != null:
		super()


func _on_mouse_entered() -> void:
	parent_menu.current_label = self
