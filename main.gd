extends Control

@onready var node_ip = $Connection/WindowConnection/LineditIP
@onready var node_port = $Connection/WindowConnection/LineditPORT
@onready var node_slot = $Connection/WindowConnection/LineditSLOT

@onready var disconnect_warning = $DisconnectWarning

var kmk: KMK = KMK.new()

@onready var client_node = $Client

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.accidental_disconnect.connect(show_disconnect_warning)
	kmk.client_node = client_node


func _on_bt_connect_pressed() -> void:
	Archipelago.connected.connect(kmk.initialize_kmk.unbind(1))
	Archipelago.connected.connect(failsafe_connect.unbind(2))
	$Connection.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	Archipelago.ap_connect(node_ip.text, node_port.text, node_slot.text)

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
