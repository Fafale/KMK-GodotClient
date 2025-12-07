extends HBoxContainer

@onready var loc_id: int = -1
@onready var trial_objective: String = ""

@onready var bt_confirm = $BtConfirm
@onready var bt_complete = $BtComplete

@onready var label = $LabelTrial


func _on_bt_copy_pressed() -> void:
	DisplayServer.clipboard_set(trial_objective)

func _on_bt_complete_pressed() -> void:
	Archipelago.send_command("LocationChecks", {"locations": [loc_id]})

func _on_bt_confirm_pressed() -> void:
	bt_complete.disabled = not bt_confirm.button_pressed
