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


func _ready():
	pass

func initBoid(window_width, window_height):
	x = rand_range(0, window_width)
	y = rand_range(0, window_height)
	dx = rand_range(0, d) - offset
	dy = rand_range(0, d) - offset
	history = []
	return self

