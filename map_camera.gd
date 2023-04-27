extends Camera2D
class_name MapCamera

var map_offset := Vector2i()
var map_position: Vector2i
var true_origin: Vector2
#	set = set_destination


func _ready():
	update_offset()
	true_origin = map_position


func _physics_process(_delta):
#	var map_origin: Vector2 = transform.get_origin()
	var speed: float = max(4, (true_origin.distance_to(map_position))/16)
	true_origin = true_origin.move_toward(map_position, speed)
	transform.origin = true_origin - Vector2(map_offset)


func _input(event):
	if event.is_action_pressed("debug"):
		update_offset()


#func _draw() -> void:
#	var screen_offset = GenVars.get_screen_size() % 16 / 2
#	var map_size = GenVars.get_map().get_size()
#	var screen_size = GenVars.get_screen_size()
#	print_debug(map_size)
#	print_debug(screen_size)
#	draw_rect(Rect2(0, 0, GenVars.get_screen_size().x, map_offset.y), Color.HOT_PINK)
#	draw_rect(Rect2(0, 0, map_offset.x, GenVars.get_screen_size().y), Color.HOT_PINK)


func set_map_position(new_map_position: Vector2i):
	if Vector2(get_destination()) == transform.get_origin():
		var map_size = GenVars.get_map().get_size()
		var screen_size = GenVars.get_screen_size()
#		map_offset = GenVars.get_screen_size() % 16 / 2
		for i in 2:
			if map_size[i] < screen_size[i]:
				new_map_position[i] = map_position[i]
			else:
				while new_map_position[i] <= -16:
					new_map_position[i] += 16
				while new_map_position[i] + screen_size[i] > (map_size[i]) + 16:
					new_map_position[i] -= 16
		map_position = GenFunc.round_coords_to_tile(new_map_position)


func move(new_map_position: Vector2i):
	set_map_position(map_position + new_map_position)


func get_low_map_position() -> Vector2i:
	return (GenVars.get_map().get_size() - GenVars.get_screen_size()) - map_position


#func center() -> void:
#	var center_pos: Vector2i
#	var size: Vector2i = GenVars.get_screen_size()
#	center_pos = Vector2i(Vector2(GenVars.get_map().get_size())/2)
#	print_debug(map_offset)
#	center_pos = GenFunc.round_coords_to_tile(center_pos, -(size % 16)/2)
#	destination = center_pos - size/2
#	print_debug(size % 16)
#	destination = GenFunc.round_coords_to_tile(destination) - (size % 16)/2
#	for coord in 2:
#		if GenVars.get_map().get_size()[coord] < size[coord]:
#			destination[coord] = center_pos[coord] - int(floor(float(size[coord])/2))
#	update_offset()


func update_offset() -> void:
	var map_size = GenVars.get_map().get_size()
	var screen_size = GenVars.get_screen_size()
	map_offset = GenVars.get_screen_size() % 16 / 2
	for i in 2:
		if map_size[i] < screen_size[i]:
			map_offset[i] = round(screen_size[i] - map_size[i])/2
	GenVars.get_cursor().move(Vector2i())
#	destination += map_offset
#	map_offset = GenVars.get_screen_size() % 16 / 2
#	destination -= map_offset
#	move(Vector2i())


func get_destination() -> Vector2i:
	return map_position - map_offset


func can_move(new_dest: Vector2i) -> bool:
	var old_pos: Vector2i = map_position
	move(new_dest)
	var answer: bool
	if map_position == old_pos:
		answer = false
	else:
		answer = true
	map_position = old_pos
	return answer
