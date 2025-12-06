class_name KMK

var available_areas: Dictionary[String, KMKArea] = {}
var available_keys:  Array[String] = []

var received_keys: Array[String] = []


func initialize_kmk(conn: ConnectionInfo) -> void:
	# initialize functions
	init_areas(conn.slot_data)
	init_keys(conn.slot_data["selected_magic_keys"])
	
	conn.obtained_item.connect(kmk_after_obtained_item)
	conn.refresh_items.connect(kmk_after_refresh_items)
	pass

# Called
func kmk_after_refresh_items(received_item: NetworkItem) -> void:
	pass

# Initialize areas in available_areas
func init_areas(slot_data: Dictionary) -> void:
	available_areas.clear()
	
	for area_name in slot_data["area_games"].keys():
		var area = KMKArea.new()
		area.game = slot_data["area_games"][area_name]
		
		if slot_data["lock_combinations"][area_name] != null:
			area.locks.assign(slot_data["lock_combinations"][area_name])
		
		area.constraints.assign(slot_data["area_game_optional_constraints"][area_name])
		
		for trial_name in slot_data["area_trials"][area_name]:
			var trial = KMKTrial.new()
			
			trial.objective = slot_data["area_trial_game_objectives"][trial_name]
			
			area.trials[trial_name] = trial
		
		available_areas[area_name] = area

# Save keys names in available_keys
func init_keys(list: Array) -> void:
	available_keys.clear()
	
	for key in list:
		available_keys.append(key)

# Print all keys, marking received ones
func print_keys() -> void:
	for key in available_keys:
		if key in received_keys:
			print("+ ", key)
		else:
			print(key)

# Update received keys in received_keys
func request_received_keys() -> void:
	received_keys.clear()
	
	Archipelago.send_command("Sync", {})

func kmk_after_obtained_item(item_list: Array[NetworkItem]):
	var data: DataCache = Archipelago.conn.get_gamedata_for_player()
	
	print("chegou aq")
	
	for item:NetworkItem in item_list:
		var item_name:String = data.get_item_name(item.id)
		print("vendo item:", item_name)
		if item_name in available_keys:
			received_keys.append(item_name)
	
