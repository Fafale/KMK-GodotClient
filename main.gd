extends Control

@onready var node_ip: LineEdit = $Connection/WindowConnection/LineditIP
@onready var node_port: LineEdit = $Connection/WindowConnection/LineditPORT
@onready var node_slot: LineEdit = $Connection/WindowConnection/LineditSLOT
@onready var node_password: LineEdit = $Connection/WindowConnection/LineditPASSWORD

@onready var disconnect_warning = $DisconnectWarning

var kmk: KMK = KMK.new()

@onready var client_node = $Client

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.accidental_disconnect.connect(show_disconnect_warning)
	kmk.client_node = client_node


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
		
		$Connection.hide()
		$Client.show()
		
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
