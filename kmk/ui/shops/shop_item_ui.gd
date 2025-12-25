extends HBoxContainer

@onready var related_loc_name: String = ""
@onready var loc_id: int = -1

@onready var bt_purchase = $BtPurchase

@onready var label = $LabelItem

func _on_bt_purchase_pressed() -> void:
	Archipelago.send_command("LocationChecks", {"locations": [loc_id]})

func update_button(loc: KMKShopLocation) -> void:
	if loc.relic_have:
		if loc.sent:
			bt_purchase.disabled = true
			bt_purchase.text = "Purchased!"
			#print("[bt from %s] -> purchased" % related_loc_name)
		else:
			bt_purchase.disabled = false
			bt_purchase.text = "Purchase"
			#print("[bt from %s] -> purchase" % related_loc_name)
	else:
		bt_purchase.disabled = true
		bt_purchase.text = "Need Relic"
		#print("[bt from %s] -> need relic" % related_loc_name)
