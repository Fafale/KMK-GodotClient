class_name KMK

const RELIC_NAMES = [
	"Abyssal Knot",
	"Ashvine Ring",
	"Astralglen Sprig",
	"Bloodroot Bulb",
	"Bogmire Amber",
	"Celestine Strand",
	"Cinder of the Lost",
	"Coralheart Fragment",
	"Duskwind Feather",
	"Echoiron Nail",
	"Emberglow Pellet",
	"Fogseed Capsule",
	"Frostwreath Shard",
	"Galechime Whistle",
	"Glasswing Brooch",
	"Glimmercoil Spring",
	"Gloomvine Tendril",
	"Heartwood Chip",
	"Hourglass of Shifting",
	"Ink of Forgotten Rites",
	"Ironroot Seed",
	"Luminweave Ribbon",
	"Maelstrom Shard",
	"Mirror of Whispers",
	"Mistbound Lantern",
	"Morrowmist Dewdrop",
	"Nightbloom Petal",
	"Nightcrown Circlet",
	"Pathfinder's Sundial",
	"Phoenix Lament Scale",
	"Quartz of Memory's Edge",
	"Resonant Bone Flute",
	"Rune of Silent Oaths",
	"Sable Quartz Bead",
	"Sands of Unmaking",
	"Scale of the Skyborn",
	"Sigil of Broken Chains",
	"Siren's Tear",
	"Soul Prism",
	"Starmark Lens",
	"Stormshackle Chain",
	"Tempest's Heart",
	"Thornmarrow Spike",
	"Thunderrift Shard",
	"Vein of Nightfire",
	"Veinstone of Echoing Lament",
	"Voidecho Sphere",
	"Vortex Prism",
	"Wisp of the Weeping Willow",
	"Wyrmcoil Ring"
]

var client_node: Control

var goal: KMKGoal

var available_areas: Dictionary[String, KMKArea] = {}

var selected_keys: Array[String] = []
var used_keys:  Array[String] = []

var received_keys: Array[String] = []

var received_relics: Array[String] = []

var is_refreshing: bool = false
var call_refresh: bool = false

var initial_refresh: bool = true
var fresh_connection: bool = true

func initialize_kmk(conn: ConnectionInfo) -> void:
	conn.refresh_items.connect(kmk_after_refresh_items)
	
	print("initialize_kmk")
	
	# initialize functions
	init_areas(conn)
	init_keys(conn.slot_data["used_magic_keys"], conn.slot_data["selected_magic_keys"])
	init_goal(conn.slot_data)

func _on_accidental_disconnect():
	print("accidental disconnect happened")
	fresh_connection = true

# Called
func kmk_after_obtained_item(_received_item: NetworkItem) -> void:
	if is_refreshing:
		print("obtained_item: queue refresh_item")
		call_refresh = true
	else:
		print("obtained_item: call refresh_item")
		is_refreshing = true
		request_sync()

# Initialize areas in available_areas
func init_areas(conn: ConnectionInfo) -> void:
	print("init_areas")
	
	var slot_data: Dictionary = conn.slot_data
	var data: DataCache = conn.get_gamedata_for_player()
	
	available_areas.clear()
	
	for area_name in slot_data["lock_combinations"].keys():
		var area = KMKArea.new()
		
		if slot_data["lock_combinations"][area_name] != null:
			area.locks.assign(slot_data["lock_combinations"][area_name])
		
		
		var possible_game = slot_data["area_games"].get(area_name, null)
		if possible_game != null:
			area.game = possible_game
			area.constraints.assign(slot_data["area_game_optional_constraints"][area_name])
			
			for trial_name in slot_data["area_trials"][area_name]:
				var trial = KMKTrial.new()
				
				trial.objective = slot_data["area_trial_game_objectives"][trial_name]
				trial.loc_id = data.get_loc_id(trial_name)
				
				trial.done = conn.slot_locations[trial.loc_id]
				
				area.trials[trial_name] = trial
		else:
			var shop: KMKShop = KMKShop.new()
			shop.initialize(slot_data["shop_data"][area_name])
			area.shop = shop
		
		available_areas[area_name] = area

func init_keys(used_list: Array, selected_list: Array) -> void:
	print("init_keys")
	
	selected_keys.clear()
	used_keys.clear()
	
	for key in used_list:
		used_keys.append(key)
	
	for key in selected_list:
		selected_keys.append(key)

func init_goal(slot_data: Dictionary) -> void:
	print("init_goal")
	goal = KMKGoal.new()
	
	goal.goal_type = slot_data["goal"]
	
	if goal.goal_type == goal.GoalTypes.GOAL_ARTIFACTS:
		goal.goal_constraints.assign(slot_data["goal_game_optional_constraints"])
		goal.goal_game = slot_data["goal_game"]
		goal.goal_objective = slot_data["goal_trial_game_objective"]
		
		goal.available_artifacts = slot_data["artifacts_of_resolve_total"]
		goal.required_artifacts = slot_data["artifacts_of_resolve_required"]
		goal.received_artifacts = 0
		
		goal.area = KMKArea.new()
		goal.area.game = goal.goal_game
		goal.area.constraints = goal.goal_constraints
		
		var trial_name = "Inside the Keymaster's Challenge Chamber: Ultimate Challenge"
		var data: DataCache = Archipelago.conn.get_gamedata_for_player()
		var goal_trial = KMKTrial.new()
		goal_trial.objective = goal.goal_objective
		goal_trial.loc_id = data.get_loc_id(trial_name)
		goal.area.trials[trial_name] = goal_trial
	elif goal.goal_type == goal.GoalTypes.GOAL_KEY_HEIST:
		goal.required_keys = slot_data["magic_keys_required"]
		goal.available_keys = slot_data["magic_keys_total"]
		goal.received_keys = 0
	elif goal.goal_type == goal.GoalTypes.GOAL_MEDALLIONS:
		goal.required_medallions = slot_data["conquest_medallions_required"]
		goal.available_medallions = len(slot_data["area_trials"])
		goal.received_medallions = 0
		pass
	

# Print all keys, marking received ones
func print_keys() -> void:
	for key in used_keys:
		if key in received_keys:
			print("+ ", key)
		else:
			print(key)

# Update received keys in received_keys
func request_sync() -> void:
	print("sent sync request")
	Archipelago.send_command("Sync", {})

func kmk_after_refresh_items(item_list: Array[NetworkItem]):
	if Archipelago.is_ap_connected():
		received_keys.clear()
		received_relics.clear()
		goal.clear()
		
		#print("refresh_items: ", item_list)
		
		var data: DataCache = Archipelago.conn.get_gamedata_for_player()
		
		for item:NetworkItem in item_list:
			var item_name:String = data.get_item_name(item.id)
			if item_name == "Artifact of Resolve":
				goal.add_artifact()
			elif item_name == "Conquest Medallion":
				goal.add_medallion()
			elif item_name == "Unlock: The Keymaster's Challenge Chamber":
				goal.unlock()
			elif item_name == "Completed: Keymaster's Keep Challenge":
				goal.complete()
			elif item_name.contains("Unlock"):
				for area_name in available_areas.keys():
					if item_name == "Unlock: " + area_name:
						available_areas[area_name].player_unlocked = true
			elif item_name.contains("Key"):
				if item_name in selected_keys:
					received_keys.append(item_name)
					goal.add_key()
			elif item_name in RELIC_NAMES:
				received_relics.append(item_name)
		
		if goal.goal_unlocked:
			available_areas[goal.area_name] = goal.area
		
		for area_name in available_areas.keys():
			var area = available_areas[area_name]
			
			if area.locked:
				area.locked = false
				for key_name in area.locks:
					if not key_name in received_keys:
						area.locked = true
			
			if area.player_unlocked:
				if not area.is_shop():
					for trial_name in area.trials.keys():
						var trial:KMKTrial = area.trials[trial_name]
						
						if Archipelago.conn.slot_locations[trial.loc_id]:
							trial.done = true
				else:
					for loc_name in area.shop.locations.keys():
						var loc:KMKShopLocation = area.shop.locations[loc_name]
						
						if Archipelago.conn.slot_locations[loc.loc_id]:
							loc.sent = true
						
						if loc.relic_name in received_relics:
							loc.relic_have = true
		
		if fresh_connection:
			fresh_connection = false
			if initial_refresh:
				initial_refresh = false
				setup_kmk_ui(available_areas, received_keys)
			Archipelago.conn.obtained_item.connect(kmk_after_obtained_item)
			Archipelago.conn.roomupdate.connect(kmk_after_room_update)
		else:
			update_kmk_ui(available_areas, received_keys)
		
		if call_refresh:
			print("refresh_item: call queued refresh")
			call_refresh = false
			request_sync()
		else:
			print("refresh_item: end of refresh queue")
			is_refreshing = false

func setup_kmk_ui(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	client_node.keep_create_areas(areas, keys, Archipelago.conn.slot_data, goal)

func update_kmk_ui(areas, keys) -> void:
	#delay
	client_node.keep_update_areas(areas, keys, goal)
	pass

func kmk_after_room_update(_json: Dictionary) -> void:
	if Archipelago.is_ap_connected():
		for area_name in available_areas.keys():
			var area = available_areas[area_name]
			
			for trial_name in area.trials.keys():
				var trial:KMKTrial = area.trials[trial_name]
				
				if Archipelago.conn.slot_locations[trial.loc_id]:
					trial.done = true
		
		client_node.keep_update_trials(available_areas, received_keys)
