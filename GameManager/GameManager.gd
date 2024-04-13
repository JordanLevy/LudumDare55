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

const COUNTDOWN_DURATION: int = 3
const ROUND_DURATION: int = 10
const ROUND_END_DURATION: int = 5

signal countdown_started
signal round_started
signal round_ended


func _ready():
	countdown_started.connect(_on_countdown_start)
	round_started.connect(_on_round_start)
	round_ended.connect(_on_round_end)
	
func _on_countdown_start():
	print("countdown")
	timer_end = Time.get_unix_time_from_system() + 3 + 10 + 5
	game_state = GameState.COUNTDOWN
	
func _on_round_start():
	print("playing")
	game_state = GameState.PLAYING
	
func _on_round_end():
	print("round end")
	game_state = GameState.ROUND_OVER
