# Used to create a map sprite from the standard FEGBA format
# Each image is exported as a .exr, conversion to .png is recommended for space reasons
# In-engine conversion to .png is flawed
@tool
extends Node2D
@export var standing_offset_y = 0


func _process(_delta: float) -> void:
	for standing in get_tree().get_nodes_in_group("Standing"):
		standing.texture = $Standing.texture
		standing.offset.y = standing_offset_y
	for walking in get_tree().get_nodes_in_group("Walking"):
		walking.texture = $Walking.texture


func _on_button_pressed() -> void:
	await get_tree().idle_frame
	var text: String = $Panel/TextEdit.text
	text = text.to_lower().replace(" ", "_")
	var image = $Parser.get_texture().get_data()
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	texture.set_storage(texture.STORAGE_COMPRESS_LOSSLESS)
	texture.set_flags(0)
	$Parser.texture = texture
	image.flip_y()
	image.convert(image.FORMAT_RGBAF)
	image.save_exr("res://Map Sprites/%s.exr" % text)
