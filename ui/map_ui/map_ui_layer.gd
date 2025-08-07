extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)


func _on_child_entered_tree(child: Node) -> void:
	if child is CanvasItem:
		(child as CanvasItem).texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
