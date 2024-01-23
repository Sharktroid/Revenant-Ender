extends ItemLabel

var parent_menu: TradeMenu


func _init() -> void:
	selectable = false


func _on_mouse_entered() -> void:
	parent_menu.current_label = self
