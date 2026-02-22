extends Node

enum LEVELS {
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	FINAL,
}

var last_level = LEVELS.LEVEL_1

var level_key: String
var quest_key: String

var levels_state = {
	"level1": {
		# 1 room
		"questLandlord": false, # update
		"quest1A": false, # history erase
	},
	"level2": {
		# 1 rooms + hallway quest
		#"questLandlord1": false, # light
		"questLandlord2": false, # tubes
		"quest2A": false, # letter
		"quest2B": false, # letter back
	},

	"level3": {
		# 1 room
		"questLandlord1": false, # breaker
		"questLandlord2": false, # update
		"questLandlord3": false, # history erase
	},
}

func complete_quest(lk: String = GameState.level_key, qk: String = GameState.quest_key):
	if levels_state.has(lk):
		if levels_state[lk].has(qk):
			levels_state[lk][qk] = true
