class_name KMK

var client_node: Control

var available_areas: Dictionary[String, KMKArea] = {}
var available_keys:  Array[String] = []

var received_keys: Array[String] = []

var is_refreshing: bool = false
var call_refresh: bool = false

var initial_refresh: bool = true

func initialize_kmk(conn: ConnectionInfo) -> void:
	conn.refresh_items.connect(kmk_after_refresh_items)
	
	# initialize functions
	init_areas(conn.slot_data)
	init_keys(conn.slot_data["used_magic_keys"])

# Called
func kmk_after_obtained_item(received_item: NetworkItem) -> void:
	if is_refreshing:
		print("obt: queue call")
		call_refresh = true
	else:
		print("obt: call")
		is_refreshing = true
		request_received_keys()

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
	print("req")
	Archipelago.send_command("Sync", {})

func kmk_after_refresh_items(item_list: Array[NetworkItem]):
	received_keys.clear()
	
	#print("refresh_items: ", item_list)
	
	var data: DataCache = Archipelago.conn.get_gamedata_for_player()
	
	for item:NetworkItem in item_list:
		var item_name:String = data.get_item_name(item.id)
		if item_name.contains("Key"):
			if item_name in available_keys:
				received_keys.append(item_name)
		elif item_name.contains("Unlock"):
			for area_name in available_areas.keys():
				if item_name == "Unlock: " + area_name:
					available_areas[area_name].player_unlocked = true
	
	for area_name in available_areas.keys():
		var area = available_areas[area_name]
		
		if area.locked:
			area.locked = false
			for key_name in area.locks:
				if not key_name in received_keys:
					area.locked = true
	
	if initial_refresh:
		initial_refresh = false
		Archipelago.conn.obtained_item.connect(kmk_after_obtained_item)
		Archipelago.conn.roomupdate.connect(kmk_after_room_update)
		setup_kmk_ui(available_areas, received_keys)
	else:
		update_kmk_ui(available_areas, received_keys)
	
	if call_refresh:
		print("ref: call ref again")
		call_refresh = false
		request_received_keys()
	else:
		print("ref: stop refresh")
		is_refreshing = false

func setup_kmk_ui(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	client_node.keep_create_areas(areas, keys)

func update_kmk_ui(areas, keys) -> void:
	#delay
	client_node.keep_update_areas(areas, keys)
	pass

func kmk_after_room_update(json: Dictionary) -> void:
	pass
