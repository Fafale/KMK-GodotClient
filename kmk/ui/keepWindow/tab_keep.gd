extends Control

@onready var area_preload = preload("res://kmk/ui/keepWindow/keep_area_ui.tscn")

@onready var list = $Scroll/List

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
					area_node.keys.append_text(" [color=medium_sea_green] %s available (%s complete)[/color] " % [available, area.trials.size() - available])
				else:
					area_node.keys.append_text(" [color=medium_sea_green] Area complete![/color]")
			else:
				area_node.button.disabled = false
				area_node.keys.clear()
				area_node.keys.append_text("[color=olive][b]Can unlock![/b][/color]")
				Archipelago.location_checked()
