extends Node

enum GameState {
	MENU,
	WAITING,
	PRE_ROUND,
	ROUND,
	POST_ROUND
}

static var game_state: GameState = GameState.MENU
static var num_players: int = 0
static var timer_end: float = 0
static var candles_belong_to = [0, 0, 0, 0, 0]
static var players: Dictionary = {}
static var controls = 0
static var mapping_p1 = ['_key', '_0', '_0']
static var mapping_p2 = ['_0', '_key', '_1']
static var is_online = true

const COUNTDOWN_DURATION: int = 3
const ROUND_DURATION: int = 10
const ROUND_END_DURATION: int = 5

signal waiting_for_opponent
signal pre_round_started
signal round_started
signal post_round_started
signal connection_code_changed
signal controls_changed
signal candle_lit

signal mute_toggled

func _ready():
	waiting_for_opponent.connect(_on_waiting_for_opponent)
	pre_round_started.connect(_on_pre_round_start)
	round_started.connect(_on_round_start)
	post_round_started.connect(_on_post_round_start)
	controls_changed.connect(_on_controls_changed)

func _on_controls_changed(config):
	controls = config

func _on_waiting_for_opponent():
	controls_changed.emit(controls)
	game_state = GameState.WAITING

func _on_pre_round_start():
	game_state = GameState.PRE_ROUND
	
func _on_round_start():
	game_state = GameState.ROUND
	
func _on_post_round_start(winner: int):
	game_state = GameState.POST_ROUND
	
func hitlag(time_scale, duration):
	Engine.time_scale = time_scale
	await(get_tree().create_timer(duration * time_scale).timeout)
	Engine.time_scale = 1.0
