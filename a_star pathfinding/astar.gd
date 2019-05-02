extends TileMap

var start : Vector2
var goal : Vector2

var is_finished : bool = false

func _ready():
	initialize()
	a_star()
	pass

func initialize(): #gets the start and the end
	start = get_used_cells_by_id(4)[0]
	goal =  get_used_cells_by_id(5)[0]

func a_star(): #algorithm
	var frontier : Dictionary = {}
	frontier[start] = 0
	var came_from : Dictionary = {}
	var cost_so_far : Dictionary = {}
	came_from[start] = null
	cost_so_far[start] = 0

	while !frontier.empty():
		yield(get_tree(), "idle_frame") #idle frame for safety
		var current = priority_list(frontier)
		frontier.erase(current)

		if current == goal: #if at goal calculate path and bail-out
			print("we reached the goal")
			current = goal
			var path = []
			while current != start:
				path.append(current)
				set_cellv(current, 3)
				current = came_from[current]
			path.append(start)
			path.invert()
			is_finished = true
			
			break

		for next in get_neighbors(current): #loops threw neighbors and calculates the cost
			var new_cost = cost_so_far[current] + get_cost(current, next)
			if !next in cost_so_far or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + heurist(goal, next)
				frontier[next] = priority
				came_from[next] = current
				yield(get_tree().create_timer(0.05), "timeout")
				set_cellv(current, 2) #animate the search

func get_neighbors(pos : Vector2): #helper function to get the neighbors
	var neighbors : Array = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			if get_cellv(pos + Vector2(x, y)) != -1:
				neighbors.append(pos + Vector2(x, y))
	return neighbors

func heurist(a, b): # Manhattan distance
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_cost(from, to): #helper function, gets cost, vertical movement, diagonal movement
	var cost
	var weight = 1
	var distance : Vector2
	
	distance = from - to
	distance = distance.abs()
	if distance == Vector2(1, 1): #diagonal
		cost = 14 * get_cell_cost(to)
		return cost
	else:
		cost = 10 * get_cell_cost(to) #vertical, horizontal
		return cost

func get_cell_cost(pos): #helper function getss cost from the cell
	match get_cellv(pos):
		0:
			return 10
		1:
			return 1
		2:
			return 2
		3:
			return 3
		_:
			return 0

func priority_list(dic : Dictionary): #list wich returns the key with the lowest priority
	var priority : Vector2 = Vector2(-1, -1)
	for key in dic:
		if priority == Vector2(-1, -1):
			priority = key
			continue
		if dic[priority] > dic[key]:
			priority = key
	return priority