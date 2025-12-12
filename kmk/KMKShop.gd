class_name KMKShop

var name: String = ""
var shopkeeper: String = ""

var locations: Dictionary[String, KMKShopLocation] = {}

func initialize(info: Dictionary) -> void:
	name = info["shop"]
	shopkeeper = info["shopkeeper"]
	
	for loc_name in info["shop_items"].keys():
		var location = KMKShopLocation.new()
		location.initialize(info["shop_items"][loc_name])
		
		locations[loc_name] = location

func count_available_items() -> int:
	var count = 0
	
	for loc: KMKShopLocation in locations.values():
		if not loc.sent:
			count += 1
	
	return count
