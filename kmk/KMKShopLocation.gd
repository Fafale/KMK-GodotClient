class_name KMKShopLocation

var sent: bool = false

var loc_id: int = -1

var relic_have: bool = false
var relic_name: String = ""
var relic_id: int = -1

var item_name: String = ""
var item_classification: int = -1
var item_player_name: String = ""
var item_player_game: String = ""

func initialize(info: Dictionary) -> void:
	loc_id = info["archipelago_id"]
	
	var relic_info = info["relic"]
	relic_name = relic_info["name"]
	relic_id = relic_info["archipelago_id"]
	relic_have = false
	
	var item_info = info["item"]
	item_name = item_info["name"]
	item_classification = item_info["classification"]
	item_player_name = Archipelago.conn.get_player_name(item_info["player"])
	item_player_game = Archipelago.conn.get_game_for_player(item_info["player"])
	
	sent = Archipelago.conn.slot_locations.get(loc_id, false)
