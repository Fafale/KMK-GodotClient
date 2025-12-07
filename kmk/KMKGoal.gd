class_name KMKGoal

const area_name = "The Keymaster's Challenge Chamber"

signal goal_trial_unlocked

var goal_type: int = -1

var area: KMKArea

var button_enabled: bool = false

var received_artifacts: int = -1
var required_artifacts: int = -1
var available_artifacts: int = -1

var goal_game: String = ""
var goal_constraints: Array[String] = []
var goal_objective: String = ""
var goal_unlocked: bool = false

var received_keys: int = -1
var available_keys: int = -1
var required_keys: int = -1

func add_artifact() -> void:
	received_artifacts += 1

func add_key() -> void:
	received_keys += 1

func unlock() -> void:
	goal_unlocked = true
	area.player_unlocked = true
	goal_trial_unlocked.emit()

func verify():
	if goal_type == 0 and received_artifacts >= required_artifacts:
		button_enabled = true
	if goal_type == 1 and received_keys >= required_keys:
		button_enabled = true

func complete() -> void:
	Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)

func clear() -> void:
	received_artifacts = 0
	received_keys = 0
	goal_unlocked = false
	button_enabled = false
