extends Control

@onready var selector = $Selector

@onready var tab_keep = $Tabs/TabKeep
@onready var tab_available = $Tabs/TabAvailable
#@onready var tab_completed = $Tabs/TabCompleted

@onready var tabs = [
	tab_keep,
	tab_available
]

func _ready() -> void:
	#selector.find_child("BtMain").pressed.connect(switch_tab.bind(tab_main))
	selector.find_child("BtKeep").pressed.connect(switch_tab.bind(tab_keep))
	selector.find_child("BtAvailable").pressed.connect(switch_tab.bind(tab_available))
	#selector.find_child("BtCompleted").pressed.connect(switch_tab.bind(tab_completed))
	#selector.find_child("BtShop").pressed.connect(switch_tab.bind(tab_shop))
	#selector.find_child("BtHint").pressed.connect(switch_tab.bind(tab_hint))

func switch_tab(selected_tab: Control) -> void:
	for tab in tabs:
		tab.hide()
	
	selected_tab.show()

func keep_create_areas(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	tab_keep.create_areas(areas, keys)

func keep_update_areas(areas: Dictionary[String, KMKArea], keys: Array[String]) -> void:
	tab_keep.update_areas(areas, keys)

func keep_update_trials(areas, keys) -> void:
	tab_keep.update_areas(areas, keys)
	#tab_trials.update_trials()
