class_name KMKArea

# Whether it's unlockable
var locked: bool = true
var locks: Array[String] = []

# If it was unlocked by the player
var player_unlocked: bool = false

var game: String = ""
var constraints: Array[String] = []


var trials: Dictionary[String, KMKTrial] = {}

func count_available_trials() -> int:
	var count = 0
	for trial in trials.values():
		if not trial.done:
			count += 1
	
	return count
