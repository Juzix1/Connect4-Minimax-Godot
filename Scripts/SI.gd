extends Node

const MAX_DEPTH: int = 4#Glebokosc rekursji w minimaxie
var AI_PLAYER: int
var YELLOW_PLAYER: int
const INF: int = 10000 #Pozytywna i negatywna nieskonczonosc
var file
var save=false

func createFile(newFile) -> void:
	file = newFile

#Ocena Planszy
func evaluate_board_after_move(board,x,y,player) -> int:
	var check = check_win_from_move(board,x,y) 
	debug("check " +str(check))
	debug("player "+str(player))
	if check == player:
		if player == AI_PLAYER:
			debug("detected PC win: gain 10000 points")
			return INF
		elif check == YELLOW_PLAYER:
			debug("detected Player win: gain -10000 points")
			return -INF
	return evaluate_board(board)
func evaluate_board(board):
	var score:int = 0

	# Iteracja przez wszystkie możliwe pola
	for y in range(6):
		for x in range(7):
			if board[y][x] == AI_PLAYER:
				score += score_position(board, x, y, AI_PLAYER)
				debug("+"+str(score_position(board, x, y, AI_PLAYER))+" points")
			elif board[y][x] == YELLOW_PLAYER:
				score -= score_position(board, x, y, YELLOW_PLAYER)
				debug("-"+str(score_position(board, x, y, YELLOW_PLAYER))+" points")
	debug("Overall score is: "+str(score))
	return score

func check_win_from_move(board,x,y)->int:
	debug(board[0])
	debug(board[1])
	debug(board[2])
	debug(board[3])
	debug(board[4])
	debug(board[5])
	debug(str(x)+"x "+str(y) + "y " + str(board[y][x]))
	var player: int = board[y][x]
	if player == 0:
		return 0

	var directions = [
		Vector2i(1, 0),   # Poziomo (prawo i lewo)
		Vector2i(0, 1),   # Pionowo (góra i dół)
		Vector2i(1, 1),   # Ukos (prawo-dół i lewo-góra)
		Vector2i(1, -1)   # Ukos (prawo-góra i lewo-dół)
	]

	# Przeiteruj przez wszystkie kierunki
	for direction in directions:
		if count_in_direction(board, x, y, direction.x, direction.y, player) >= 4:
			#debug("check_from_move:" +str(player))
			return player  # Jeśli znaleziono zwycięstwo, zwróć identyfikator gracza
	#debug("check_from_move:" +str(0))
	return 0  # Brak zwycięzcy
	
func check_win_from_move2(board,x,y)->int:
	
	var player: int = board[y][x]
	if player == 0:
		return 0

	var directions = [
		Vector2i(1, 0),   # Poziomo (prawo i lewo)
		Vector2i(0, 1),   # Pionowo (góra i dół)
		Vector2i(1, 1),   # Ukos (prawo-dół i lewo-góra)
		Vector2i(1, -1)   # Ukos (prawo-góra i lewo-dół)
	]

	# Przeiteruj przez wszystkie kierunki
	for direction in directions:
		if count_in_direction(board, x, y, direction.x, direction.y, player) >= 4:
			#debug("check_from_move:" +str(player))
			return player  # Jeśli znaleziono zwycięstwo, zwróć identyfikator gracza
	#debug("check_from_move:" +str(0))
	return 0  # Brak zwycięzcy

func score_position(board,x,y,player)->int:
	var directions = [
		Vector2i(1, 0),   # Poziomo
		Vector2i(0, 1),   # Pionowo
		Vector2i(1, 1),   # Ukos dolny prawy
		Vector2i(1, -1)   # Ukos górny prawy
	]
	var score: int = 0
	for direction in directions:
		var count:int = count_in_direction(board, x, y, direction.x, direction.y, player)
		if count == 2:
			score += 5
			#debug("Added 5 points")
		elif count == 3:
			score += 50
			#debug("Added 50 points")
		elif count == 4:
			score += 1000	# Wygrana
			#debug("Added 1000 points")
	return score

func count_in_direction(board, x, y, dx, dy, player)->int:
	var count:int = 1  # Include the starting position
	# Check in the positive direction
	count += count_one_direction(board, x, y, dx, dy, player)
	# Check in the negative direction
	count += count_one_direction(board, x, y, -dx, -dy, player)
	return count

func count_one_direction(board, x, y, dx, dy, player)->int:
	var count:int = 0
	var nx:int = x + dx
	var ny:int = y + dy
	while nx >= 0 and nx < 7 and ny >= 0 and ny < 6 and board[ny][nx] == player:
		count += 1
		nx += dx
		ny += dy
	return count

#pokaz dostepne ruchy (tam gdzie nie ma jeszcze coinów)
func get_valid_moves(board):
	var valid_moves = []
	for x in range(7):  # Iterate through all columns (0-6)
		if board[0][x] == 0:  # Check if the topmost row of the column is empty
			valid_moves.append(x)
	return valid_moves

#Algorytm Minimax
# Minimax function to simulate both AI and Player moves
func minimax(board, depth, maximizing_player, alpha, beta, last_move) -> int:
	if depth == 0 or (last_move != null and check_win_from_move2(board, last_move.x, last_move.y) != 0):
		if last_move != null:
			return evaluate_board_after_move(board, last_move.x, last_move.y, AI_PLAYER if maximizing_player else YELLOW_PLAYER)
		else:
			return evaluate_board(board)
	
	var valid_moves = get_valid_moves(board)
	
	if maximizing_player:
		# AI's turn (maximizing player)
		var max_eval = -INF
		for move in valid_moves:
			make_move(board, move, AI_PLAYER)
			var eval = minimax(board, depth - 1, false, alpha, beta, Vector2i(move, get_last_row(board, move)))
			undo_move(board, move)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
		return max_eval
	else:
		# Player's turn (minimizing player)
		var min_eval = INF
		for move in valid_moves:
			make_move(board, move, YELLOW_PLAYER)
			var eval = minimax(board, depth - 1, true, alpha, beta, Vector2i(move, get_last_row(board, move)))
			undo_move(board, move)
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha:
				break
		return min_eval

#wykonaj ruch
func make_move(board,x, team)->void:
	for i in range(len(board)):
		if board[-i-1][x] == 0:
			board[-i-1][x] = team
			break

#cofnij ruch
func undo_move(board,x)->void:
	for i in range(len(board)):
		if board[i][x] != 0:
			board[i][x] = 0
			break

#znajdź najkorzystniejszy ruch dla komputera
func find_best_move(board)->int:
	var best_move:int = -1
	var best_value:int = -INF
	var valid_moves = get_valid_moves(board)
	
	debug("Starting Process of making best move")
	
	for move in valid_moves:
		make_move(board,move, AI_PLAYER) #AI gra czerwonym
		debug("move "+ str(move))
		debug("Making a real move")
		var row:int = get_last_row(board,move)
		
		var move_value:int = minimax(board, MAX_DEPTH,false,-INF,INF,Vector2i(move,row))
		debug("move_value "+str(move_value))
		debug("best_value "+str(best_value))
		#debug("undo the virtual move in: "+str(move)+"column")
		
		undo_move(board, move)
		if move_value > best_value:
			best_value = move_value
			best_move = move
	debug("Best move is in column "+str(best_move+1))
	return best_move
			
func get_last_row(board,column):
	for y in range(6):
		if board[y][column] != 0:
			return y
	return 5
func setPlayers(AI,yellow):
	AI_PLAYER=AI
	YELLOW_PLAYER=yellow
func toggleSave():
	save=not save
	
func debug(message):
	if save:
		var result : String = message
		file.store_string(result+"\n")
		print(message)
