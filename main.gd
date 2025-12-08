extends Control

@onready var node_ip: LineEdit = $Connection/WindowConnection/LineditIP
@onready var node_port: LineEdit = $Connection/WindowConnection/LineditPORT
@onready var node_slot: LineEdit = $Connection/WindowConnection/LineditSLOT
@onready var node_password: LineEdit = $Connection/WindowConnection/LineditPASSWORD

@onready var disconnect_warning = $ReconnectWarning

@onready var window_client = $Client
@onready var window_connection = $Connection

var kmk: KMK = KMK.new()

@onready var client_node = $Client

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(handle_connection.unbind(2))
	Archipelago.accidental_disconnect.connect(show_disconnect_warning)
	kmk.client_node = client_node
	
	if Archipelago.reconnect_queue:
		Archipelago.reconnect_queue = false
		show_disconnect_warning()
		
		Archipelago.connected.connect(kmk.initialize_kmk.unbind(1))
		Archipelago.connected.connect(failsafe_connect.unbind(2))
		
		window_connection.hide()
		window_client.show()
		
		await get_tree().create_timer(1.0).timeout
		
		Archipelago.ap_connect(Archipelago.reconnect_ip, Archipelago.reconnect_port, Archipelago.reconnect_slot, Archipelago.reconnect_password)
		
		await get_tree().create_timer(5.0).timeout
		
		if not Archipelago.is_ap_connected():
			Archipelago.reconnect_queue = true
			show_disconnect_warning()


func _on_bt_connect_pressed() -> void:
	var able_to_connect = true
	if node_ip.text.is_empty():
		able_to_connect = false
	if not node_port.text.is_valid_int():
		able_to_connect = false
	if node_slot.text.is_empty():
		able_to_connect = false
	
	if able_to_connect:
		Archipelago.connected.connect(kmk.initialize_kmk.unbind(1))
		Archipelago.connected.connect(failsafe_connect.unbind(2))
		
		window_connection.hide()
		window_client.show()
		
		await get_tree().create_timer(1.0).timeout
		
		Archipelago.ap_connect(node_ip.text, node_port.text, node_slot.text, node_password.text)

# Failsafe against bad/first connections
func failsafe_connect() -> void:
	if kmk.initial_refresh:
		kmk.kmk_after_refresh_items([])
	if kmk.initial_refresh:
		await get_tree().create_timer(5.0).timeout
		kmk.kmk_after_refresh_items([])
	if kmk.initial_refresh:
		await get_tree().create_timer(10.0).timeout
		kmk.kmk_after_refresh_items([])

func show_disconnect_warning():
	disconnect_warning.show()
	
	if Archipelago.reconnect_queue:
		await get_tree().create_timer(1.0).timeout
		get_parent().reset_main()

func handle_connection():
	disconnect_warning.hide()
	
	window_connection.hide()
	window_client.show()
	
	if Archipelago.reconnect_ip == "":
		Archipelago.reconnect_ip = node_ip.text
		Archipelago.reconnect_port = node_port.text
		Archipelago.reconnect_slot = node_slot.text
		Archipelago.reconnect_password = node_password.text
