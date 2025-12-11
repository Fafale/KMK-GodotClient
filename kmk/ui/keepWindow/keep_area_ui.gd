extends HBoxContainer

@onready var related_area_name: String = ""

@onready var button = $BtUnlock
@onready var title = $LabelTitle
@onready var keys = $LabelKeys


func _on_bt_unlock_pressed() -> void:
	if Archipelago.is_ap_connected():
		var data = Archipelago.conn.get_gamedata_for_player()
		
		var loc_id = data.get_loc_id("Unlock: " + related_area_name)
		Archipelago.send_command("LocationChecks", {"locations": [loc_id]})
