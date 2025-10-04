extends Control


var _awaiting: bool = false


func _ready() -> void:
	OS.add_logger(CrashHandlerLogger.new(_handle_crash))
	#_handle_crash(Logger.ERROR_TYPE_SCRIPT, "Test", Engine.capture_script_backtraces())


func _handle_crash(
	error_type: Logger.ErrorType, rationale: String, script_backtraces: Array[ScriptBacktrace]
) -> void:
	if not is_inside_tree():
		return
	var backtrace_string: String = "\n".join(
		script_backtraces.map(func(backtrace: ScriptBacktrace) -> String: return backtrace.format())
	)
	var get_error_name: Callable = func() -> String:
		match error_type:
			Logger.ErrorType.ERROR_TYPE_WARNING:
				return "Warning"
			Logger.ErrorType.ERROR_TYPE_SCRIPT:
				return "A script error has occured"
			Logger.ErrorType.ERROR_TYPE_SHADER:
				return "A shader error has occured"
			_:
				return "An error has occured"
	var get_error_color: Callable = func() -> Color:
		match error_type:
			Logger.ErrorType.ERROR_TYPE_WARNING:
				return Color.YELLOW
			Logger.ErrorType.ERROR_TYPE_SCRIPT:
				return Color.PURPLE
			Logger.ErrorType.ERROR_TYPE_SHADER:
				return Color.CYAN
			_:
				return Color.RED

	var error_name: String = get_error_name.call()
	var error_color: Color = get_error_color.call()
	var error_label := Label.new()
	error_label.text = error_name
	error_label.add_theme_color_override(&"font_color", error_color)
	%VBoxContainer.add_child(error_label)

	var rationale_label := Label.new()
	rationale_label.text = rationale
	rationale_label.add_theme_color_override(&"font_color", error_color)
	%VBoxContainer.add_child(rationale_label)
	var string_array: Array[String] = [backtrace_string]
	for string: String in string_array:
		var label := Label.new()
		label.text = string
		%VBoxContainer.add_child(label)

	var reset_label := Label.new()
	var set_save_text: Callable = func(dots: int) -> void:
		reset_label.text = "Saving log%s" % ".".repeat(dots)
	var text_tween: Tween = create_tween()
	text_tween.tween_callback(set_save_text.bind(1)).set_delay(1)
	text_tween.tween_callback(set_save_text.bind(2)).set_delay(1)
	text_tween.tween_callback(set_save_text.bind(3)).set_delay(1)
	text_tween.set_loops()
	text_tween.set_speed_scale(2)
	set_save_text.call(3)
	%VBoxContainer.add_child(reset_label)

	var control_label := Label.new()
	control_label.text = ""
	%VBoxContainer.add_child(control_label)

	get_tree().paused = true
	var file_name: String = "crash_D{date_time}.log".format(
		{"date_time": Time.get_datetime_string_from_system().replace("T", "_T").replace(":", "-")}
	)
	DirAccess.make_dir_absolute("user://crash_logs/")
	var file := FileAccess.open("user://crash_logs/"+file_name, FileAccess.WRITE)
	if file:
		file.store_string("\n".join([error_name, rationale, backtrace_string]))
		file.flush()
		reset_label.text = 'A log has been saved to "%s"' % file_name
		reset_label.add_theme_color_override(&"font_color", Color.GREEN)
	else:
		reset_label.text = 'Could not write file "%s"' % file_name
		reset_label.add_theme_color_override(&"font_color", Color.RED)
	control_label.text = "Press [Select] to restart."
	text_tween.stop()
	await get_tree().process_frame
	_awaiting = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and _awaiting:
		get_tree().reload_current_scene()


class CrashHandlerLogger:
	extends Logger

	var crash_handler_callable: Callable

	func _init(callable: Callable) -> void:
		crash_handler_callable = callable

	func _log_error(
		_function: String,
		_file: String,
		_line: int,
		code: String,
		rationale: String,
		_editor_notify: bool,
		error_type: Logger.ErrorType,
		script_backtraces: Array[ScriptBacktrace]
	) -> void:
		crash_handler_callable.call(error_type, code + rationale, script_backtraces)
