extends Control

@onready var node_ip = $ConnectionInfo/LineditIP
@onready var node_port = $ConnectionInfo/LineditPORT
@onready var node_slot = $ConnectionInfo/LineditSLOT

var kmk: KMK = KMK.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_connect_pressed() -> void:
	Archipelago.ap_connect(node_ip.text, node_port.text, node_slot.text)
	Archipelago.connected.connect(kmk.initialize_kmk.unbind(1))


func _on_bt_exec_pressed() -> void:
	if false:
		print(Archipelago.conn.slot_data["area_games"]) # dict with everything
	
	# load slot info
	var data = Archipelago.conn.get_gamedata_for_player()
	
	print(Archipelago.location_list()) # all available ids
	
	# return the loc name
	print(data.get_loc_name(4))
	print(data.get_loc_name(20))
	print(data.get_loc_name(36))
	print(data.get_loc_name(40))
	
	# return the loc id (access by name), or -1 if don't exist
	print(data.get_loc_id("Unlock: The Cloaked Entrance"))
	
	pass # Replace with function body.


func _on_bt_test_pressed() -> void:
	if true:
		kmk.init_areas(Archipelago.conn.slot_data)
		# kmk.load_keys(Archipelago.conn.slot_data["selected_magic_keys"])
	
	if false:
		kmk.print_keys()
	
	if false:
		kmk.request_received_keys()
		
	#kmk.print_keys()
	pass # Replace with function body.
