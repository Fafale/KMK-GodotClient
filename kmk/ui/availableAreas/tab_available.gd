extends Control

@onready var area_preload = preload("res://kmk/ui/availableAreas/available_area_ui.tscn")
@onready var trial_preload = preload("res://kmk/ui/availableAreas/trial_info_ui.tscn")

@onready var added_areas = []

@onready var list = $Scroll/List

func create_areas(areas: Dictionary[String, KMKArea]) -> void:
	for area_name in areas.keys():
		var area = areas[area_name]
		
		if area.player_unlocked and (not area.is_shop()):
			if area.count_available_trials() > 0:
				add_area_node(area_name, area)
			else:
				send_area_completion(area_name)

func update_areas(areas: Dictionary[String, KMKArea]) -> void:
	for area_name in areas.keys():
		var area = areas[area_name]
		
		if (not area_name in added_areas) and area.player_unlocked and (not area.is_shop()):
			if area.count_available_trials() > 0:
				add_area_node(area_name, area)
			else:
				send_area_completion(area_name)

func update_trials(areas: Dictionary[String, KMKArea]) -> void:
	if Archipelago.is_ap_connected():
		var areas_to_delete = []
		
		var area_list = list.get_children()
		for area_node in area_list:
			var area = areas[area_node.related_area_name]
			if area.count_available_trials() == 0:
				send_area_completion(area_node.related_area_name)
				areas_to_delete.append(area_node)
			else:
				for trial_node in area_node.trial_nodes:
					if Archipelago.conn.slot_locations[trial_node.loc_id]:
						trial_node.hide()
		
		for node in areas_to_delete:
			node.queue_free()

func add_area_node(area_name: String, area: KMKArea) -> void:
	var area_node = area_preload.instantiate()
	list.add_child(area_node)
	
	added_areas.append(area_name)
	
	area_node.related_area_name = area_name
	area_node.label.clear()
	area_node.label.append_text("[b][font_size=20]%s[/font_size] - %s[/b]" % [area_name, area.game])
	if not area.constraints.is_empty():
		area_node.label.append_text("[br][color=gray][font_size=14]Optional Conditions: ")
	for constraint in area.constraints:
		area_node.label.append_text(constraint)
	
	for trial_name in area.trials.keys():
		var trial:KMKTrial = area.trials[trial_name]
		
		if not trial.done:
			var trial_node = trial_preload.instantiate()
			area_node.add_child(trial_node)
			area_node.trial_nodes.append(trial_node)
			
			trial_node.loc_id = trial.loc_id
			trial_node.trial_objective = trial.objective
			
			trial_node.label.clear()
			trial_node.label.append_text("[b]%s[/b][br][color=gray]%s[/color]" % [trial_name, trial.objective])

func send_area_completion(area_name):
	var data = Archipelago.conn.get_gamedata_for_player()
	var complete_loc_id = data.get_loc_id("Complete: " + area_name)
	if complete_loc_id != -1:
		Archipelago.send_command("LocationChecks", {"locations": [complete_loc_id]})
