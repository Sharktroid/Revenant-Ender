# Used to create a map sprite from the standard FE GBA format
# Each image is exported as a .exr, conversion to .png is recommended for space reasons
# In-engine conversion to .png is flawed
@tool
extends Node2D
@export var standing_offset_y: float = 0


func _process(_delta: float) -> void:
	for standing: Sprite2D in get_tree().get_nodes_in_group("Standing") as Array[Sprite2D]:
		standing.texture = ($Standing as Sprite2D).texture
		standing.offset.y = standing_offset_y
	for walking: Sprite2D in get_tree().get_nodes_in_group("Walking") as Array[Sprite2D]:
		walking.texture = ($Walking as Sprite2D).texture


func _on_button_pressed() -> void:
	var text: String = ($Panel/TextEdit as TextEdit).text
	text = text.capitalize()
	#var image: Image = ($Parser as Sprite2D).get_texture().get_data()
	#var texture := ImageTexture.create_from_image(image)
	#texture.set_storage(texture.STORAGE_COMPRESS_LOSSLESS)
	#texture.set_flags(0)
	#$Parser.texture = texture
	#image.flip_y()
	#image.convert(image.FORMAT_RGBAF)
	#image.save_exr("res://MapSprites/%s.exr" % text)
