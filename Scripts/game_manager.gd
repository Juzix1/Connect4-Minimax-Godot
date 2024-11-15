extends Node

@onready var tilemap: TileMapLayer = $"../CanvasLayer/TileMapLayer"
@onready var ai: Node = preload("res://Scripts/SI.gd").new()

const MAIN_SOURCE_ID = 0
const RED_TOKEN = Vector2i(0,0)
const YELLOW_TOKEN = Vector2i(1,0)
const EMPTY_TOKEN = Vector2i(0,1)
var board = []
var player_team

func _ready() -> void:
	player_team = 1#randi_range(1,2)
	init_Board()
#	Debug the board


			
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		
		
		debug_board()
		
func init_Board():
#	SETUP BOARD IN TERMINAL
	for i in range(6):
		board.append([])
		for j in range(7):
			board[i].append(0)
			tilemap.set_cell(Vector2i(j,i),MAIN_SOURCE_ID,EMPTY_TOKEN)
			
func insert_Coin(x,team):
	var token
	for i in range(len(board)):
		if board[-i-1][x] == 0:
			board[-i-1][x] = team
			if team==1:
				token=RED_TOKEN
			else:
				token=YELLOW_TOKEN
			tilemap.set_cell(Vector2i(x,-i+len(board)-1),MAIN_SOURCE_ID,token)
			break
	if len(ai.get_valid_moves(board)) >=4:
		if ai.connectWin(board) != 0:
			print("team "+str(ai.connectWin(board))+" wins")



func debug_board():
	for i in range(len(board)):
		print(board[i])
	print("------")

func make_move(column):
	insert_Coin(column,player_team)
	%moveDelay.start()
func _on_button_pressed() -> void:
	make_move(0)


func _on_button_2_pressed() -> void:
	make_move(1)


func _on_button_3_pressed() -> void:
	make_move(2)


func _on_button_4_pressed() -> void:
	make_move(3)


func _on_button_5_pressed() -> void:
	make_move(4)


func _on_button_6_pressed() -> void:
	make_move(5)


func _on_button_7_pressed() -> void:
	make_move(6)


func _on_move_delay_timeout() -> void:
	if player_team == 2: #Jeśli gracz to żółty, AI wykona ruch
		var best_move = ai.find_best_move(board)
		insert_Coin(best_move, 1)
	else:
		var best_move = ai.find_best_move(board)
		insert_Coin(best_move, 2)
