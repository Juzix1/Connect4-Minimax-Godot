extends Node

@onready var tilemap: TileMapLayer = $"../CanvasLayer/TileMapLayer"
@onready var ai: Node = preload("res://Scripts/SI.gd").new()
@onready var epoch: Timer = $"../ElapsedTimer"

const MAIN_SOURCE_ID = 0
const RED_TOKEN = Vector2i(0,0)
const YELLOW_TOKEN = Vector2i(1,0)
const EMPTY_TOKEN = Vector2i(0,1)
var board = []
var player_team
var start_time
var time_now

func _ready() -> void:
	player_team = 1#randi_range(1,2)
	ai.setPlayers(player_team,2 if player_team==1 else 1)
	ai.createFile(FileAccess.open("user://logs/log.txt", FileAccess.WRITE_READ))
	init_Board()


	



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		ai.toggleSave()
		
		#debug_board()

		
func init_Board():
	# Clear any existing board state
	board.clear()
	# Define a predefined board state
	var predefined_board = [
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0], 
		[0, 0, 0, 0, 0, 0, 0], 
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
	]
	
	# Initialize the board and the TileMap based on the predefined state
	for i in range(6):
		board.append([])
		for j in range(7):
			var cell_value = predefined_board[i][j]
			board[i].append(cell_value)
			# Set TileMap cell based on the token
			if cell_value == 1:
				tilemap.set_cell(Vector2i(j, i), MAIN_SOURCE_ID, RED_TOKEN)
			elif cell_value == 2:
				tilemap.set_cell(Vector2i(j, i), MAIN_SOURCE_ID, YELLOW_TOKEN)
			else:
				tilemap.set_cell(Vector2i(j, i), MAIN_SOURCE_ID, EMPTY_TOKEN)
			debug_board()

func insert_Coin(x, team):
	var token
	var inserted_row = -1  # Track the row where the coin is inserted
	for i in range(len(board)):
		if board[-i - 1][x] == 0:
			board[-i - 1][x] = team
			inserted_row = len(board) - i - 1  # Save the row index
			if team == 1:
				token = RED_TOKEN
			else:
				token = YELLOW_TOKEN
			tilemap.set_cell(Vector2i(x, inserted_row), MAIN_SOURCE_ID, token)
			debug_board()
			break
	
	## Check for a win only if a valid move was made
	if inserted_row != -1:
		if check_win_from_move(board, x, inserted_row) != 0:
			print("Team " + str(check_win_from_move(board, x, inserted_row)) + " wins")
			disable_all_buttons()
			%moveDelay.queue_free()
					
func disable_all_buttons():
	var hbox = $"../CanvasLayer/Control/HBoxContainer"
	for child in hbox.get_children():
		if child is Button:
			child.disabled = true

func enable_all_buttons():
	var hbox = $"../CanvasLayer/Control/HBoxContainer"
	for child in hbox.get_children():
		if child is Button:
			child.disabled = false
func check_win_from_move(board, x, y):
	var player = board[y][x]
	if player == 0:
		return 0  # No player at this position, no need to check

	# Check all possible directions for a win
	for direction in [
		Vector2i(1, 0),   # Horizontal (right)
		Vector2i(-1, 0),  # Horizontal (left)
		Vector2i(0, 1),   # Vertical (down)
		Vector2i(0, -1),  # Vertical (up)
		Vector2i(1, 1),   # Diagonal (down-right)
		Vector2i(-1, -1), # Diagonal (up-left)
		Vector2i(-1, 1),  # Diagonal (down-left)
		Vector2i(1, -1)   # Diagonal (up-right)
	]:
		if count_in_direction(board, x, y, direction.x, direction.y, player) >= 4:
			return player  # Return the winning team (1 or 2)
	return 0  # No winner
	
func count_in_direction(board, x, y, dx, dy, player):
	var count = 1  # Include the starting position
	# Check in the positive direction
	count += count_one_direction( x, y, dx, dy, player)
	# Check in the negative direction
	count += count_one_direction( x, y, -dx, -dy, player)
	return count

func count_one_direction( x, y, dx, dy, player):
	var count = 0
	var nx = x + dx
	var ny = y + dy
	while nx >= 0 and nx < 7 and ny >= 0 and ny < 6 and board[ny][nx] == player:
		count += 1
		nx += dx
		ny += dy
	return count

func debug_board():
	for i in range(len(board)):
		print(board[i])
	print("------")

func make_move(column):
	insert_Coin(column,player_team)
	%moveDelay.start()
	disable_all_buttons()
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
	enable_all_buttons()
	if player_team == 2: #Jeśli gracz to żółty, AI wykona ruch
		#start_time = Time.get_ticks_msec()
		var best_move = ai.find_best_move(board)
		insert_Coin(best_move, 1)
		#elapsedTime()

	else:
		#start_time = Time.get_ticks_msec()
		var best_move = ai.find_best_move(board)
		insert_Coin(best_move, 2)
		#elapsedTime()
		


func elapsedTime():
		time_now = Time.get_ticks_msec()
		var duration = time_now - start_time
		print(str(time_now)+", "+str(start_time))
		print("Elapsed "+str(duration)+" ms")
