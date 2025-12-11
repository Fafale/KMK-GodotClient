extends Control

@onready var area_preload = preload("res://kmk/ui/keepWindow/keep_area_ui.tscn")

@onready var list = $Scroll/List

@onready var label_info = $SideBar/LabelInfo
@onready var label_goal = $SideBar/LabelGoal
@onready var bt_goal = $SideBar/BtGoal

const GOAL_UNLOCK_ITEM_NAME = "Unlock: The Keymaster's Challenge Chamber"
var button_function = -1


func create_areas(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	for area_name in areas.keys():
		var area = areas[area_name]
		
		var area_node = area_preload.instantiate()
		list.add_child(area_node)
		
		area_node.related_area_name = area_name
		area_node.title.text = "[b]" + area_name + "[/b]"
		
		area_node.keys.clear()
		area_node.keys.append_text("[b]Needs:[/b] ")
		var lock_num = area.locks.size()
		var first = true
		for i in range(lock_num):
			var key_name = area.locks[i]
			if not key_name in keys:
				if not first:
					area_node.keys.add_text(", ")
				else:
					first = false
				area_node.keys.add_text(key_name)
	
	verify_locks(areas)

func update_areas(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	var area_list = list.get_children()
	for area_node in area_list:
		var area = areas[area_node.related_area_name]
		
		area_node.keys.clear()
		area_node.keys.append_text("[b]Needs:[/b] ")
		var lock_num = area.locks.size()
		var first = true
		for i in range(lock_num):
			var key_name = area.locks[i]
			if not key_name in keys:
				if not first:
					area_node.keys.add_text(", ")
				else:
					first = false
				area_node.keys.add_text(key_name)
	
	verify_locks(areas)

func verify_locks(areas: Dictionary[String, KMKArea]) -> void:
	var area_list = list.get_children()
	for area_node in area_list:
		var area = areas[area_node.related_area_name]
		if not area.locked:
			if area.player_unlocked:
				area_node.button.disabled = true
				area_node.button.text = "Unlocked"
				area_node.keys.clear()
				area_node.keys.append_text("[b]Game:[/b] " + area.game)
				
				var available = area.count_available_trials()
				if available > 0:
					area_node.keys.append_text(" [color=medium_sea_green] %s available" % [available])
					var sz = area.trials.size()
					if available != sz:
						area_node.keys.append_text(" (%s complete)" % [sz - available])
				else:
					area_node.keys.append_text(" [color=medium_sea_green] Area complete![/color]")
			else:
				area_node.button.disabled = false
				area_node.keys.clear()
				area_node.keys.append_text("[color=olive]Can unlock![/color]")

func set_sidebar_info(slot_data: Dictionary) -> void:
	label_info.clear()
	label_info.append_text("[b]Seed Information[/b][br]")
	
	label_info.append_text("[font_size=14]Keep Areas: [color=medium_sea_green]%d[/color][br]" % slot_data["lock_combinations"].size())
	label_info.append_text("Magic Keys: [color=medium_sea_green]%d[/color][br]" % slot_data["magic_keys_total"])
	label_info.append_text("Unlocked Areas: [color=medium_sea_green]%d[/color][br]" % slot_data["unlocked_areas"])
	label_info.append_text("Lock Magic Keys (Minimum): [color=medium_sea_green]%d[/color][br]" % slot_data["lock_magic_keys_minimum"])
	label_info.append_text("Lock Magic Keys (Maximum): [color=medium_sea_green]%d[/color][br]" % slot_data["lock_magic_keys_maximum"])
	label_info.append_text("Area Trials (Minimum): [color=medium_sea_green]%d[/color][br]" % slot_data["area_trials_minimum"])
	label_info.append_text("Area Trials (Maximum): [color=medium_sea_green]%d[/color][br]" % slot_data["area_trials_maximum"])
	
	label_info.append_text("[font_size=4][br][/font_size]Shops: ")
	if slot_data["shops"]:
		label_info.append_text("[color=medium_sea_green]On[/color][br]")
		label_info.append_text("Shops Chance: [color=medium_sea_green]%d%%[/color][br]" % slot_data["shops_percentage_chance"])
		label_info.append_text("Shop Items (Minimum): [color=medium_sea_green]%d[/color][br]" % slot_data["shop_items_minimum"])
		label_info.append_text("Shop Items (Maximum): [color=medium_sea_green]%d[/color][br]" % slot_data["shop_items_maximum"])
		label_info.append_text("Shop Items Progression Chance: [color=medium_sea_green]%d%%[/color][br]" % slot_data["shop_items_progression_percentage_chance"])
		label_info.append_text("Shop Hints: [color=medium_sea_green]%s[/color][br][font_size=4][br][/font_size]" % ["On" if slot_data["shop_hints"] else "Off"])
	else:
		label_info.append_text("[color=medium_sea_green]Off[/color][br]")
	
	label_info.append_text("Game Medley Mode: [color=medium_sea_green]%s%s[/color][br]" % ["On" if slot_data["game_medley_mode"] else "Off", ("(%s%% chance)" % slot_data["game_medley_percentage_chance"]) if slot_data["game_medley_mode"] else ""])
	
	label_info.append_text("[font_size=4][br][/font_size]Include +18 / Unrated Games: [color=medium_sea_green]%s[/color][br]" % ["On" if slot_data["include_adult_only_or_unrated_games"] else "Off"])
	label_info.append_text("Include Modern Console Games: [color=medium_sea_green]%s[/color][br]" % ["On" if slot_data["include_modern_console_games"] else "Off"])
	label_info.append_text("Include Difficult Objectives: [color=medium_sea_green]%s[/color][br]" % ["On" if slot_data["include_difficult_objectives"] else "Off"])
	label_info.append_text("Include Time Consuming Objectives: [color=medium_sea_green]%s[/color][br]" % ["On" if slot_data["include_time_consuming_objectives"] else "Off"])
	
	label_info.append_text("[font_size=4][br][/font_size]Hint Reveal Objectives: [color=medium_sea_green]%s[/color]" % ["On" if slot_data["hints_reveal_objectives"] else "Off"])

func set_goal_info(goal: KMKGoal) -> void:
	label_goal.clear()
	
	label_goal.append_text("[b][font_size=16]Goal[/font_size][/b][br]")
	label_goal.append_text("[font_size=14]")
	
	if goal.goal_type == 0:
		label_goal.append_text("[b]Keymaster's Challenge[/b][br]")
		label_goal.append_text("Retrieve Artifacts of Resolve to unlock the Keymaster's Challenge Chamber and beat the ultimate challenge![br]")
		
		label_goal.append_text("[b]Artifacts of Resolve[/b][br]")
		label_goal.append_text("Retrieved [color=medium_sea_green]%d[/color] of [color=medium_sea_green]%d[/color] needed ([color=darkgray]%d total[/color])" % [goal.received_artifacts, goal.required_artifacts, goal.available_artifacts])
		
		if goal.goal_unlocked:
			bt_goal.text = "Challenge Chamber Unlocked!"
		else:
			bt_goal.text = "Unlock Challenge Chamber"
	else:
		label_goal.append_text("[b]Magic Key Heist[/b][br]")
		label_goal.append_text("Retrieve Magic Keys throughout the Keymaster's Keep and escape![br]")
		
		label_goal.append_text("[b]Artifacts of Resolve[/b][br]")
		label_goal.append_text("Retrieved [color=medium_sea_green]%d[/color] of [color=medium_sea_green]%d[/color] needed ([color=darkgray]%d total[/color])" % [goal.received_keys, goal.required_keys, goal.available_keys])
		
		bt_goal.text = "Claim Victory!"
	
	button_function = goal.goal_type
	
	goal.verify()
	var bt_enable = goal.button_enabled and not goal.goal_unlocked
	bt_goal.disabled = not bt_enable


func _on_bt_goal_pressed() -> void:
	if Archipelago.is_ap_connected():
		if button_function == 0:
			var data = Archipelago.conn.get_gamedata_for_player()
			var loc_id = data.get_loc_id(GOAL_UNLOCK_ITEM_NAME)
			Archipelago.send_command("LocationChecks", {"locations": [loc_id]})
		elif button_function == 1:
			Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)
