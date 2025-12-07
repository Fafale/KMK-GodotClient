extends Control

@onready var node_ip = $Connection/WindowConnection/LineditIP
@onready var node_port = $Connection/WindowConnection/LineditPORT
@onready var node_slot = $Connection/WindowConnection/LineditSLOT

var kmk: KMK = KMK.new()

@onready var client_node = $Client

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kmk.client_node = client_node


func _on_bt_connect_pressed() -> void:
	Archipelago.connected.connect(kmk.initialize_kmk.unbind(1))
	$Connection.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	Archipelago.ap_connect(node_ip.text, node_port.text, node_slot.text)
	
	# Failsafe against bad/first connections
	if kmk.initial_refresh:
		kmk.kmk_after_refresh_items([])
	if kmk.initial_refresh:
		await get_tree().create_timer(5.0).timeout
		kmk.kmk_after_refresh_items([])
	if kmk.initial_refresh:
		await get_tree().create_timer(10.0).timeout
		kmk.kmk_after_refresh_items([])


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
	if false:
		kmk.init_areas(Archipelago.conn)
		# kmk.load_keys(Archipelago.conn.slot_data["selected_magic_keys"])
	
	if false:
		kmk.print_keys()
	
	if true:
		kmk.request_received_keys()
		
	#kmk.print_keys()
	pass # Replace with function body.
