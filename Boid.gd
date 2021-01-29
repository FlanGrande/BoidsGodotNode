extends Node2D

class_name Boid

# Boid's x, y origin
var x = 0
var y = 0
# Boid's direction vector
var dx = 0
var dy = 0
var d = 20
var offset = 10
# Boid history of positions?
var history = []
var historyLength = 20

var trailEnabled = false
var trailColor = Color(1.0, 0.0, 0.0, 1.0)
var trailWidth = 1.0
var trailLine2D : Line2D

func _ready():
	z_index = 1
	pass

func initBoid(window_width, window_height, trail_enabled, trail_color, trail_width, history_length):
	x = rand_range(0, window_width)
	y = rand_range(0, window_height)
	dx = rand_range(0, d) - offset
	dy = rand_range(0, d) - offset
	history = []
	trailEnabled = trail_enabled
	trailColor = trail_color
	trailWidth = trail_width
	historyLength = history_length
	
	if(trailEnabled):
		trailLine2D = Line2D.new()
		trailLine2D.default_color = trailColor
		trailLine2D.default_color = Color(rand_range(0, 1),rand_range(0, 1),rand_range(0, 1))
		trailLine2D.width = trailWidth
		trailLine2D.z_index = -1
		add_child(trailLine2D)
	
	return self

func _process(delta):
	trailLine2D.clear_points()
	if(trailEnabled):
		for point in history:
			trailLine2D.add_point(to_local(Vector2(point[0], point[1])))

func addToHistory(var point : Vector2, var index : int):
	history.push_back(point)
	
	if(history.size() > historyLength): # This will probably give me some issues.
		history.pop_front() # This will probably give me some issues.
		trailLine2D.remove_point(0)
