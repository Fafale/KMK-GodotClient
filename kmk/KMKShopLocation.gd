class_name KMKShopLocation

var sent: bool = false

var loc_id: int = -1

var relic_name: String = ""
var relic_id: int = -1

var item_name: String = ""
var item_classification: int = -1
var item_player_name: String = ""

func initialize(info: Dictionary) -> void:
	loc_id = info["archipelago_id"]
	
	var relic_info = info["relic"]
	relic_name = relic_info["name"]
	relic_id = relic_info["archipelago_id"]
	
	var item_info = info["item"]
	item_name = item_info["name"]
	item_classification = item_info["classification"]
	item_player_name = Archipelago.conn.get_player_name(item_info["player"])
	
	sent = Archipelago.conn.slot_locations.get(loc_id, false)
