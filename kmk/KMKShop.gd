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
