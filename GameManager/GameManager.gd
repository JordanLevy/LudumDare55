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
static var candles_belong_to = [0, 0, 0, 0, 0]
static var players: Dictionary = {}

const COUNTDOWN_DURATION: int = 3
const ROUND_DURATION: int = 10
const ROUND_END_DURATION: int = 5

signal countdown_started
signal round_started
signal round_ended

signal mute_toggled


func _ready():
	countdown_started.connect(_on_countdown_start)
	round_started.connect(_on_round_start)
	round_ended.connect(_on_round_end)
	
func _on_countdown_start():
	timer_end = Time.get_unix_time_from_system() + 3 + 10 + 5
	game_state = GameState.COUNTDOWN
	
func _on_round_start():
	game_state = GameState.PLAYING
	
func _on_round_end(winner: int):
	game_state = GameState.ROUND_OVER
