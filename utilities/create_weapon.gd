@tool
extends EditorScript

func _run() -> void:
	var all_weapons: = FileAccess.open("res://utilities/weapons.csv", FileAccess.READ)
	var file_array: Array[String] = []
	file_array.assign(all_weapons.get_as_text(true).split("\n"))
	for weapon_line: String in file_array:
		var weapon_name: String = weapon_line.get_slice(",", 0)
		var weapon_type: String = weapon_line.get_slice(",", 1)
		var weapon_file: String = """class_name {class_name}
extends {type}


func _init() -> void:
	resource_name = "{name}"
	_rank = Ranks.{level}
	_max_uses = {durability}
	_price =
	super()""".format({
		"class_name": weapon_name.to_pascal_case(),
		"type": weapon_type.to_pascal_case(),
		"name": weapon_name,
		"level": weapon_line.get_slice(",", 13),
		"durability": weapon_line.get_slice(",", 11),
	})
		#print(weapon_file)
		var directory: String = "res://items/weapons/{type}/{weapon_name}".format({
			"type": weapon_type.to_snake_case() + ("" if weapon_type in ["Anima", "Eldritch", "Holy", "Siege"] else "s"),
			"weapon_name": weapon_name.to_snake_case()
		})
		var file_name: String = "{weapon_name}.gd".format({
			"weapon_name": weapon_name.to_snake_case()
		})
		var file_path: String = "{directory}/{file_name}".format({
			"directory": directory,
			"file_name": file_name
		})
		#if not FileAccess.file_exists(file_path):
		DirAccess.make_dir_recursive_absolute(directory)
		var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(weapon_file)
		file.close()
		print("File created: ", file_path)
		#else:
			#print("File already exists: ", file_path)
