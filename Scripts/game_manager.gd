extends Node

@onready var tilemap: TileMapLayer = $"../CanvasLayer/TileMapLayer"
const MAIN_SOURCE_ID = 0
const RED_TOKEN = Vector2i(0,0)
const YELLOW_TOKEN = Vector2i(1,0)
const EMPTY_TOKEN = Vector2i(0,1)
var board = []

func _ready() -> void:

	init_Board()
#	Debug the board

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		insert_Coin(randi_range(0,6),randi_range(1,2))
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

#TODO
#Winning methods/Checking for 4-streak tokens
#Debug
func debug_board():
	for i in range(len(board)):
		print(board[i])
	print("------")
