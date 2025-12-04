class_name KMK

var available_doors: Array[String] = []
var available_keys:  Array[String] = []

var received_keys: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Save doors names in available_doors
func load_doors(dict: Dictionary) -> void:
	available_doors.clear()
	
	for door in dict.keys():
		available_doors.append(door)

# Save keys names in available_keys
func load_keys(list: Array) -> void:
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
	
	Archipelago.conn.connect("refresh_items", assign_received_keys)
	
	print("enviando o comando")
	Archipelago.send_command("Sync", {})

func assign_received_keys(item_list: Array[NetworkItem]):
	var data: DataCache = Archipelago.conn.get_gamedata_for_player()
	
	print("chegou aq")
	
	for item:NetworkItem in item_list:
		var item_name:String = data.get_item_name(item.id)
		print("vendo item:", item_name)
		if item_name in available_keys:
			received_keys.append(item_name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
