extends Node

const MAX_DEPTH = 5#Glebokosc rekursji w minimaxie
const RED_PLAYER = 1
const YELLOW_PLAYER = 2
const INF = 10000 #Pozytywna i negatywna nieskonczonosc

#Ocena Planszy
func evaluate_board_after_move(board,x,y,player):
	if check_win_from_move(board,x,y) ==player:
		if player == RED_PLAYER:
			return 1000
		else:
			return -1000
	return evaluate_board(board)
func evaluate_board(board):
	var score = 0
	
	# Iteracja przez wszystkie możliwe pola
	for y in range(6):
		for x in range(7):
			if board[y][x] == RED_PLAYER:
				score += score_position(board, x, y, RED_PLAYER)
			elif board[y][x] == YELLOW_PLAYER:
				score -= score_position(board, x, y, YELLOW_PLAYER)
	return score

func check_win_from_move(board,x,y):
	var player = board[y][x]
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
			return player  # Jeśli znaleziono zwycięstwo, zwróć identyfikator gracza
	return 0  # Brak zwycięzcy

func score_position(board,x,y,player):
	var directions = [
		Vector2i(1, 0),   # Poziomo
		Vector2i(0, 1),   # Pionowo
		Vector2i(1, 1),   # Ukos dolny prawy
		Vector2i(1, -1)   # Ukos górny prawy
	]
	var score = 0
	for direction in directions:
		var count = count_in_direction(board, x, y, direction.x, direction.y, player)
		if count == 2:
			score += 5
		elif count == 3:
			score += 50
		elif count == 4:
			score += 1000  # Wygrana
	return score
	
func count_in_direction(board, x, y, dx, dy, player):
	var count = 1  # Include the starting position
	# Check in the positive direction
	count += count_one_direction(board, x, y, dx, dy, player)
	# Check in the negative direction
	count += count_one_direction(board, x, y, -dx, -dy, player)
	return count

func count_one_direction(board, x, y, dx, dy, player):
	var count = 0
	var nx = x + dx
	var ny = y + dy
	while nx >= 0 and nx < 7 and ny >= 0 and ny < 6 and board[ny][nx] == player:
		count += 1
		nx += dx
		ny += dy
	return count
#sprawdz czy gracz wygral
func check_winner(board):
	# Sprawdzanie poziomych, pionowych i ukośnych linii
	for y in range(6):
		for x in range(7):
			if board[y][x] != 0:  # Jeśli pole nie jest puste
				# Sprawdzenie czterech kierunków
				if check_direction(board, x, y, 1, 0, board[y][x]) or check_direction(board, x, y, 0, 1, board[y][x]) or check_direction(board, x, y, 1, 1, board[y][x]) or check_direction(board, x, y, 1, -1, board[y][x]):
					return board[y][x]  # Zwrócenie zwycięzcy
	return 0  # Brak zwycięzcy
#Sprawdź czy są 4 coiny w rzędzie
func check_direction(board,x,y,dx,dy,player):
	var count = 0
	for i in range(4):
		var nx = x + i * dx
		var ny = y + i * dy
		if nx >= 0 and nx < 7 and ny >= 0 and ny< 6 and board[ny][nx] == player:
			count +=1
		else:
			break
	return count==4

#pokaz dostepne ruchy (tam gdzie nie ma jeszcze coinów)
func get_valid_moves(board):
	var valid_moves = []
	for x in range(7):  # Iterate through all columns (0-6)
		if board[0][x] == 0:  # Check if the topmost row of the column is empty
			valid_moves.append(x)
	return valid_moves
		
#Algorytm Minimax
func minimax(board, depth, maximizing_player, alpha, beta, last_move):
	if depth == 0 or (last_move != null and check_win_from_move(board, last_move.x, last_move.y) != 0):
		if last_move != null:
			return evaluate_board_after_move(board, last_move.x, last_move.y, RED_PLAYER if maximizing_player else YELLOW_PLAYER)
		else:
			return evaluate_board(board)
	
	var valid_moves = get_valid_moves(board)
	if maximizing_player:
		var max_eval = -INF
		for move in valid_moves:
			make_move(board, move, RED_PLAYER)
			var eval = minimax(board, depth - 1, false, alpha, beta, Vector2i(move, get_last_row(board,move)))
			undo_move(board, move)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
		#debug_minimax_evaluation(move,depth,max_eval)
		return max_eval
	else:
		var min_eval = INF
		for move in valid_moves:
			make_move(board, move, YELLOW_PLAYER)
			var eval = minimax(board, depth - 1, true, alpha, beta, Vector2i(move,get_last_row(board, move)))
			undo_move(board, move)
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha:
				break
		return min_eval
#wykonaj ruch
func make_move(board,x, team):
	for i in range(len(board)):
		if board[-i-1][x] == 0:
			board[-i-1][x] = team
			break
#cofnij ruch
func undo_move(board,x):
	for i in range(len(board)):
		if board[i][x] != 0:
			board[i][x] = 0
			break
#znajdź najkorzystniejszy ruch dla komputera
func find_best_move(board):
	var best_move = -1
	var best_value = -INF
	var valid_moves = get_valid_moves(board)
	
	for move in valid_moves:
		make_move(board,move, RED_PLAYER) #AI gra czerwonym
		var row = get_last_row(board,move)
		var move_value = minimax(board, MAX_DEPTH-1,false,-INF,INF,Vector2i(move,row))
		undo_move(board, move)
		if move_value > best_value:
			best_value = move_value
			best_move = move
	return best_move
			
func debug_minimax_evaluation(depth, maximizing_player, move, eval, alpha, beta):
	if maximizing_player:
		print("Depth:", depth, "Player:", "RED (AI)")
	else:
		print("Depth:", depth, "Player:", "Yellow (Player)")
	print("Move:", move, "Evaluation:", eval, "Alpha:", alpha, "Beta:", beta)
	print("----------------------------")
func get_last_row(board,column):
	for y in range(6):
		if board[y][column] != 0:
			return y
		return -1
