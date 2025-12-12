extends Control

@onready var area_preload = preload("res://kmk/ui/shops/shop_title_ui.tscn")
@onready var item_preload = preload("res://kmk/ui/shops/shop_item_ui.tscn")

@onready var added_areas = []

@onready var list = $Scroll/List

func create_areas(areas: Dictionary[String, KMKArea]) -> void:
	for area_name in areas.keys():
		var area = areas[area_name]
		
		if area.player_unlocked and area.is_shop():
			add_area_node(area_name, area)

func update_areas(areas: Dictionary[String, KMKArea]) -> void:
	for area_name in areas.keys():
		var area = areas[area_name]
		
		if (not area_name in added_areas) and area.player_unlocked and area.is_shop():
			add_area_node(area_name, area)
	
	update_locations(areas)

func update_locations(areas: Dictionary[String, KMKArea]) -> void:
	if Archipelago.is_ap_connected():
		#var areas_to_delete = []
		#
		var area_list = list.get_children()
		for area_node in area_list:
			var area = areas[area_node.related_area_name]
			#if area.count_available_trials() == 0:
				#areas_to_delete.append(area_node)
			#else:
				#for trial_node in area_node.trial_nodes:
					#if Archipelago.conn.slot_locations[trial_node.loc_id]:
						#trial_node.hide()
		#
		#for node in areas_to_delete:
			#node.queue_free()
		
			for loc_node in area_node.shop_items:
				loc_node.update_button(area.shop.locations[loc_node.related_loc_name])

func add_area_node(area_name: String, area: KMKArea) -> void:
	var area_node = area_preload.instantiate()
	list.add_child(area_node)
	
	added_areas.append(area_name)
	
	area_node.related_area_name = area_name
	area_node.label.clear()
	area_node.label.append_text("[b][font_size=20]%s[/font_size]\nShopkeeper:[/b] %s" % [area.shop.name, area.shop.shopkeeper])
	
	for loc_name in area.shop.locations:
		var loc:KMKShopLocation = area.shop.locations[loc_name]
		
		var loc_node = item_preload.instantiate()
		area_node.add_child(loc_node)
		area_node.shop_items.append(loc_node)
		
		loc_node.loc_id = loc.loc_id
		loc_node.related_loc_name = loc_name
		
		loc_node.label.clear()
		loc_node.label.append_text("[color=medium_purple][b]%s[/b][/color]   " % [loc.item_name])
		
		var item_class_name = "Filler"
		if   loc.item_classification & 0b0001: item_class_name = "Progression"
		elif loc.item_classification & 0b0010: item_class_name = "Useful"
		elif loc.item_classification & 0b0100: item_class_name = "Trap"
		loc_node.label.append_text("[b]Type:[/b] %s   " % [item_class_name])
		
		loc_node.label.append_text("[b]Original Owner:[/b] [color=dark_violet]%s[/color] of [color=medium_slate_blue]%s[/color]   [b]Price:[/b] 1x [color=medium_sea_green]%s[/color]" % [loc.item_player_name, loc.item_player_game, loc.relic_name])
		
		loc_node.update_button(loc)
