# this script will hold the overall game state

extends Node


var Screens = {
	MAIN_MENU = 'res://screens/main_menu.tscn',
	GAME = 'res://screens/game.tscn',
}


enum {
	SPLASH,
	MAIN_MENU,
	START_GAME,
	GAME,
	PAUSED,
	GAME_OVER
}

var _current_state: int = SPLASH
var _valid_state_changes = {
	SPLASH: [MAIN_MENU],
	MAIN_MENU: [START_GAME],
	START_GAME: [GAME],
	GAME: [PAUSED, GAME_OVER],
	PAUSED: [GAME, MAIN_MENU],
	GAME_OVER: [MAIN_MENU]
}

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	
func start_game():
	transition_to(START_GAME)
	

func is_transition_valid(next_state: int) -> bool:
	return next_state in _valid_state_changes[_current_state]


# change the state to the next
func transition_to(new_state: int) -> void:
	if !is_transition_valid(new_state):
		return
	
	_current_state = new_state
	
	match new_state:
		MAIN_MENU:
			SceneLoader.goto_scene(Screens.MAIN_MENU)
		
		START_GAME:
			SceneLoader.goto_scene(Screens.GAME)
			transition_to(GAME)


# pause handler
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed('ui_pause'):
			match _current_state:
				GAME:
					transition_to(PAUSED)
			
				PAUSED:
					transition_to(GAME)
