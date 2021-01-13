extends Node2D

# Based on: https://github.com/beneater/boids/blob/master/boids.js

onready var boid_scene = preload("res://Boid.tscn")

var window_width = OS.get_window_size().x
var window_height = OS.get_window_size().y

const numBoids = 100
const visualRange = 75

var boids = []


func _ready():
	for i in range(numBoids):
		var new_boid = boid_scene.instance()
		boids.push_back(new_boid.initBoid(window_width, window_height))
		add_child(new_boid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for boid in boids:
		# Update the velocities according to each rule
		flyTowardsCenter(boid)
		avoidOthers(boid)
		matchVelocity(boid)
		limitSpeed(boid)
		keepWithinBounds(boid)
		
		#Update the position based on the current velocity
		boid.x += boid.dx;
		boid.y += boid.dy;
		boid.history.push_back([boid.x, boid.y])
		if(boid.history.size() > 50): # This will probably give me some issues.
			boid.history.pop_front() # This will probably give me some issues.
		
		drawBoid(boid)


# Constrain a boid to within the window. If it gets too close to an edge,
# nudge it back in and reverse its direction.
func keepWithinBounds(boid):
	var margin = 50 # CONST?
	var turnFactor = 1 # CONST?
	
	if (boid.x < margin):
		boid.dx += turnFactor
		
	if (boid.x > window_width - margin):
		boid.dx -= turnFactor
		
	if (boid.y < margin):
		boid.dy += turnFactor
		
	if (boid.y > window_height - margin):
		boid.dy -= turnFactor


# Find the center of mass of the other boids and adjust velocity slightly to
# point towards the center of mass.
func flyTowardsCenter(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var centeringFactor = 0.005; # adjust velocity by this % # CONST?
	
	var centerX = 0;
	var centerY = 0;
	var numNeighbors = 0;
	
	for otherBoid in boids:
		var otherBoidPosition = Vector2(otherBoid.x, otherBoid.y)
		if(boidPosition.distance_to(otherBoidPosition) < visualRange):
			centerX += otherBoid.x
			centerY += otherBoid.y
			numNeighbors += 1
	
	if(numNeighbors >= 0):
		centerX = centerX / numNeighbors
		centerY = centerY / numNeighbors
		boid.dx += (centerX - boid.x) * centeringFactor
		boid.dy += (centerY - boid.y) * centeringFactor


# Move away from other boids that are too close to avoid colliding
func avoidOthers(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var minDistance = 20 # The distance to stay away from other boids # CONST?
	var avoidFactor = 0.05 # Adjust velocity by this % # CONST?
	var moveX = 0
	var moveY = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector2(otherBoid.x, otherBoid.y)
		if(otherBoid != boid): # Is it really different as in javascript?
			if(boidPosition.distance_to(otherBoidPosition) < minDistance):
				moveX += boid.x - otherBoid.x;
				moveY += boid.y - otherBoid.y;
	
	boid.dx += moveX * avoidFactor
	boid.dy += moveY * avoidFactor

# Find the average velocity (speed and direction) of the other boids and
# adjust velocity slightly to match.
func matchVelocity(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var matchingFactor = 0.05 # Adjust by this % of average velocity # CONST?
	
	var avgDX = 0
	var avgDY = 0
	var numNeighbors = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector2(otherBoid.x, otherBoid.y)
		if(boidPosition.distance_to(otherBoidPosition) < visualRange):
			avgDX += otherBoid.dx
			avgDY += otherBoid.dy
			numNeighbors += 1
	
	if(numNeighbors >= 0):
		avgDX = avgDX / numNeighbors
		avgDY = avgDY / numNeighbors
		
		boid.dx += (avgDX - boid.dx) * matchingFactor
		boid.dy += (avgDY - boid.dy) * matchingFactor

# Speed will naturally vary in flocking behavior, but real animals can't go
# arbitrarily fast.
func limitSpeed(boid : Boid):
	var speedLimit = 5 # CONST?
	var speed = sqrt(boid.dx * boid.dx + boid.dy * boid.dy) # CONST?
	
	if(speed > speedLimit):
		boid.dx = (boid.dx / speed) * speedLimit
		boid.dy = (boid.dy / speed) * speedLimit

func drawBoid(boid : Boid):
	boid.position = Vector2(boid.x, boid.y)
	boid.rotation = atan2(boid.dy, boid.dx)
	#move_to
	#draw_trail
	pass
