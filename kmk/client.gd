extends Control

@onready var selector = $Selector

@onready var tab_keep = $Tabs/TabKeep
@onready var tab_available = $Tabs/TabAvailable
#@onready var tab_completed = $Tabs/TabCompleted
@onready var tab_shop = $Tabs/TabShops

@onready var tabs = [
	tab_keep,
	tab_available,
	tab_shop
]

func _ready() -> void:
	#selector.find_child("BtMain").pressed.connect(switch_tab.bind(tab_main))
	selector.find_child("BtKeep").pressed.connect(switch_tab.bind(tab_keep))
	selector.find_child("BtAvailable").pressed.connect(switch_tab.bind(tab_available))
	#selector.find_child("BtCompleted").pressed.connect(switch_tab.bind(tab_completed))
	selector.find_child("BtShop").pressed.connect(switch_tab.bind(tab_shop))
	#selector.find_child("BtHint").pressed.connect(switch_tab.bind(tab_hint))

func switch_tab(selected_tab: Control) -> void:
	for tab in tabs:
		tab.hide()
	
	selected_tab.show()

func keep_create_areas(areas: Dictionary[String, KMKArea], keys: Array[String], slot_data: Dictionary, goal: KMKGoal) -> void:
	tab_keep.create_areas(areas, keys)
	tab_keep.set_sidebar_info(slot_data)
	tab_keep.set_goal_info(goal)
	tab_available.create_areas(areas)
	tab_shop.create_areas(areas)

func keep_update_areas(areas: Dictionary[String, KMKArea], keys: Array[String], goal: KMKGoal) -> void:
	tab_keep.update_areas(areas, keys)
	tab_available.update_areas(areas)
	tab_keep.set_goal_info(goal)
	tab_shop.update_areas(areas)

func keep_update_trials(areas, keys) -> void:
	tab_keep.update_areas(areas, keys)
	tab_available.update_trials(areas)
	tab_shop.update_locations(areas)
