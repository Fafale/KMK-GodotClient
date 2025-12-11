extends Control

@onready var node_ip: LineEdit = $Connection/WindowConnection/LineditIP
@onready var node_port: LineEdit = $Connection/WindowConnection/LineditPORT
@onready var node_slot: LineEdit = $Connection/WindowConnection/LineditSLOT
@onready var node_password: LineEdit = $Connection/WindowConnection/LineditPASSWORD

@onready var disconnect_warning = $DisconnectWarning
@onready var disconnect_label = $DisconnectWarning/Label

var kmk: KMK = KMK.new()

@onready var client_node = $Client

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kmk.client_node = client_node
	
	Archipelago.accidental_disconnect.connect(kmk._on_accidental_disconnect)
	
	Archipelago.accidental_disconnect.connect(_on_accidental_disconnect)
	Archipelago.reconnect_attempted.connect(_on_reconnect_attempted)
	Archipelago.reconnect_gave_up.connect(_on_reconnect_gave_up)
	Archipelago.connected.connect(_on_reconnect.unbind(2))


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

func _on_accidental_disconnect():
	disconnect_warning.show()
	
	disconnect_label.clear()
	disconnect_label.append_text("[font_size=30]Lost connection to Server.\n\nTrying to reconnect...")

func _on_reconnect():
	disconnect_warning.hide()

func _on_reconnect_attempted(attempt: int):
	disconnect_label.clear()
	disconnect_label.append_text("[font_size=30]Lost connection to Server.\n\nReconnection attempt: %d/50" % [attempt+1])

func _on_reconnect_gave_up():
	disconnect_label.clear()
	disconnect_label.append_text("[font_size=30]Lost connection to Server.\n\nToo many attempts, giving up!")
