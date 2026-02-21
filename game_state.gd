extends Node

enum LEVELS {
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
}

var last_level = LEVELS.LEVEL_1

var level1 = {
	# 1 room
	"questLandlord": false, # update
	"quest1A": false, # history erase
}

var level2 = {
	# 1 rooms + hallway quest
	"questLandlord1": false, # light
	"questLandlord2": false, # tubes
	"quest2A": false, # letter
	"quest2B": false, # letter back
}

var level3 = {
	# 1 room
	"questLandlord1": false, # breaker
	"questLandlord2": false, # update
	"questLandlord3": false, # history erase
}
