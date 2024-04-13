extends Node

enum GameState {
	MENU,
	COUNTDOWN,
	PLAYING,
	ROUND_OVER
}

static var game_state: GameState = GameState.MENU
static var num_players: int = 0
static var timer_end: float = 0

signal countdown_started
signal round_started


func _ready():
	countdown_started.connect(_on_countdown_start)
	round_started.connect(_on_round_start)
	
func _on_countdown_start():
	print("countdown")
	game_state = GameState.COUNTDOWN
	timer_end = Time.get_unix_time_from_system() + 3
	
func _on_round_start():
	print("playing")
	game_state = GameState.PLAYING
	timer_end = Time.get_unix_time_from_system() + 60
