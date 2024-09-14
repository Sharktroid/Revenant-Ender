@tool
extends Map

const DEBUG_CUTSCENE: bool = false


func _init() -> void:
	# Initializing variables for this map.
	all_factions = [
		Faction.new(
			"Roy's Army",
			Faction.Colors.BLUE,
			Faction.PlayerTypes.HUMAN,
			preload("res://audio/music/beyond_distant_skies.ogg")
		),
		Faction.new(
			"Bandits",
			Faction.Colors.RED,
			Faction.PlayerTypes.COMPUTER,
			preload("res://audio/music/deer_of_the_plains.ogg"),
			true
		),
	]
	super()


func _intro() -> void:
	if DEBUG_CUTSCENE:
		CursorController.disable()
		var roy := $MapLayer/Units/Player/Roy as Unit
		var marcus := $MapLayer/Units/Player/Marcus as Unit
		var alen := $MapLayer/Units/Player/Alen as Unit
		var lance := $MapLayer/Units/Player/Lance as Unit
		var wolt := $MapLayer/Units/Player/Wolt as Unit
		var bors := $MapLayer/Units/Player/Bors as Unit
		var dialogue: Dialogue = _get_dialogue()
		await get_tree().process_frame
		GameController.add_to_input_stack(dialogue)
		await dialogue.show_top_text_box(Dialogue.Positions.CLOSE_RIGHT)
		dialogue.add_portrait(roy, Dialogue.Positions.CLOSE_RIGHT)
		dialogue.add_portrait(lance, Dialogue.Positions.MID_LEFT, true)
		await dialogue.set_top_speaker(roy)
		await dialogue.set_top_text(
			"Oh, it's Lance! What's the matter?\nWhy are you in such a hurry?"
		)
		await dialogue.show_bottom_text_box(Dialogue.Positions.MID_LEFT)
		await dialogue.set_bottom_speaker(lance)
		await dialogue.set_bottom_text(
			"Lord Roy! Bandits have appeared and are attacking the castle as we speak!"
		)
		dialogue.add_portrait(alen, Dialogue.Positions.FAR_RIGHT)
		await dialogue.set_top_speaker(alen)
		await dialogue.set_top_text("No! Is the marquess unharmed?")
		await dialogue.clear_bottom()
		await dialogue.set_bottom_text(
			"He's inside, defending against the bandits' attack.\n"
			+ "But I don't know how long he can last with his illness...!"
		)
		await dialogue.remove_portrait(alen)
		dialogue.add_portrait(bors, Dialogue.Positions.FAR_RIGHT)
		await dialogue.set_top_speaker(bors)
		await dialogue.set_top_text("Excuse me. Lance, is it? Is Lady Lilina safe?")
		await dialogue.clear_bottom()
		await dialogue.set_bottom_text(
			"You must be a knight of Ostia. Lady Lilina is in the castle. "
			+ "She should be all right.\n"
			+ "She's with Lord Eliwood after all, but he can't last forever."
		)
		dialogue.remove_portrait(bors)
		await dialogue.set_top_speaker(roy)
		await dialogue.set_top_text("No... I shouldn't have let Lilina go to the castle before me.")
		await dialogue.remove_portrait(lance)
		dialogue.add_portrait(wolt, Dialogue.Positions.FAR_LEFT, true)
		await dialogue.set_bottom_speaker(wolt)
		await dialogue.set_bottom_text(
			"Lord Roy, regret won't solve anything! We must retake the castle!"
		)
		dialogue.add_portrait(marcus, Dialogue.Positions.CLOSE_LEFT, true)
		await dialogue.set_bottom_speaker(marcus)
		await dialogue.set_bottom_text("Wolt is right. We must make haste!")
		await dialogue.clear_top()
		dialogue.remove_portrait(wolt)
		await dialogue.remove_portrait(marcus)
		await dialogue.hide_bottom_text_box()
		await dialogue.set_top_text(
			"Yes, you're right. This is no time to despair. Very well.\n"
			+ "To arms then! Our target is the castle! We must rescue everyone!"
		)
		await dialogue.remove_portrait(roy)
		await dialogue.hide_top_text_box()
		GameController.remove_from_input_stack()
		CursorController.enable()
