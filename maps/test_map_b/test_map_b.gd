@tool
extends Map

const DEBUG_CUTSCENE: bool = false

func _init():
	# Initializing variables for this map.
	faction_stack = [
		Faction.new("Player", Faction.colors.BLUE, Faction.player_types.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.player_types.HUMAN),
	]


func _ready() -> void:
	super()
	if DEBUG_CUTSCENE:
		await MapController.get_cursor().ready
		MapController.get_cursor().disable()
		var roy: Unit = $"Map Layer/Units/Player/Roy"
		var marcus: Unit = $"Map Layer/Units/Player/Marcus"
		var alen: Unit = $"Map Layer/Units/Player/Alen"
		var lance: Unit = $"Map Layer/Units/Player/Lance"
		var wolt: Unit = $"Map Layer/Units/Player/Wolt"
		var bors: Unit = $"Map Layer/Units/Player/Bors"
		var dialogue: Dialogue = MapController.get_dialogue()
		await get_tree().process_frame
		await dialogue.show_top_textbox(Dialogue.positions.CLOSERIGHT)
		dialogue.add_portrait(roy, Dialogue.positions.CLOSERIGHT)
		dialogue.add_portrait(lance, Dialogue.positions.MIDLEFT, true)
		await dialogue.set_top_speaker(roy)
		await dialogue.set_top_text("Oh, it's Lance! What's the matter? Why are you in such a hurry?")
		await dialogue.show_bottom_textbox(Dialogue.positions.MIDLEFT)
		await dialogue.set_bottom_speaker(lance)
		await dialogue.set_bottom_text("Lord Roy! Bandits have appeared and are \
	attacking the castle as we speak!")
		dialogue.add_portrait(alen, Dialogue.positions.FARRIGHT)
		await dialogue.set_top_speaker(alen)
		await dialogue.set_top_text("No! Is the marquess unharmed?")
		await dialogue.clear_bottom()
		await dialogue.set_bottom_text("He's inside, defending against the bandits' attack. \
	But I don't know how long he can last with his illness...!")
		await dialogue.remove_portrait(alen)
		dialogue.add_portrait(bors, Dialogue.positions.FARRIGHT)
		await dialogue.set_top_speaker(bors)
		await dialogue.set_top_text("Excuse me. Lance, is it? Is Lady Lilina safe?")
		await dialogue.clear_bottom()
		await dialogue.set_bottom_text("You must be a knight of Ostia. \
	Lady Lilina is in the castle. She should be all right. \
	She's with Lord Eliwood after all, but he can't last forever.")
		dialogue.remove_portrait(bors)
		await dialogue.set_top_speaker(roy)
		await dialogue.set_top_text("No... I shouldn't have let Lilina go to the castle before me.")
		await dialogue.remove_portrait(lance)
		dialogue.add_portrait(wolt, Dialogue.positions.FARLEFT, true)
		await dialogue.set_bottom_speaker(wolt)
		await dialogue.set_bottom_text("Lord Roy, regret won't solve anything! \
	We must retake the castle!")
		dialogue.add_portrait(marcus, Dialogue.positions.CLOSELEFT, true)
		await dialogue.set_bottom_speaker(marcus)
		await dialogue.set_bottom_text("Wolt is right. We must make haste!")
		await dialogue.clear_top()
		dialogue.remove_portrait(wolt)
		await dialogue.remove_portrait(marcus)
		await dialogue.hide_bottom_textbox()
		await dialogue.set_top_text("Yes, you're right. This is no time to despair. Very well. \
	To arms then! Our target is the castle! We must rescue everyone!")
		await dialogue.remove_portrait(roy)
		await dialogue.hide_top_textbox()
		MapController.get_cursor().enable()
