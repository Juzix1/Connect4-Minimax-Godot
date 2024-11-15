extends Node

const MAX_DEPTH = 5#Glebokosc rekursji w minimaxie
const RED_PLAYER = 1
const YELLOW_PLAYER = 2
const INF = 10000 #Pozytywna i negatywna nieskonczonosc

#funkcja sprawdzająca wygranego na planszy -> GameMaganaer.gd
func connectWin(board):
	for y in range(6):
		for x in range(7):
			if board[y][x] != 0:
				var player = board[y][x]
				for direction in [
					Vector2i(1,0), #Poziomo (w prawo)
					Vector2i(-1,0), #Poziomo ( w lewo)
					Vector2i(0,1), #Pionowo ( w dół)
					Vector2i(0,-1), # Pionowo (w górę)
					Vector2i(1,1), # Ukos (w prawo i w dół)
					Vector2i(-1,-1), #Ukos (w lewo i w górę)
					Vector2i(-1,1), #Ukos (w lewo i w dół)
					Vector2i(1,-1), #Ukos (w prawo i w górę
				]:
					match check_direction(board,x,y, direction.x,direction.y, player):
						true:
							return player #Wygrany team 1 albo 2
					
	return 0 #brak wygranego


#Ocena Planszy
func evaluate_board(board):
	var winner = check_winner(board)
	if winner == RED_PLAYER:
		return 1000
	elif winner == YELLOW_PLAYER:
		return -1000
	return 0 
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
func minimax(board, depth, maximizing_player, alpha, beta):
	if depth ==0 or check_winner(board) != 0:
		return evaluate_board(board)
	
	var valid_moves = get_valid_moves(board)
	
	if maximizing_player:
		var max_eval = -INF
		for move in valid_moves:
			make_move(board,move,RED_PLAYER) # wykonaj ruch wirtualny dla czerwonego gracza(team 1)
			var eval = minimax(board,depth-1,false,alpha,beta)
			undo_move(board,move)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
		return max_eval
	else: #przeciwnik żółty
		var min_eval = INF
		for move in valid_moves:
			make_move(board,move, YELLOW_PLAYER) #wykonaj ruch wirtualny dla żółtego gracza(team 2)
			var eval = minimax(board,depth -1, true, alpha,beta)
			undo_move(board,move)
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
		var move_value = minimax(board,MAX_DEPTH,true,-INF,INF)
		undo_move(board, move)
		if move_value > best_value:
			best_value = move_value
			best_move = move
	return best_move
			
