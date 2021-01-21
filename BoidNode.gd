extends Node2D

# Based on: https://github.com/beneater/boids/blob/master/boids.js

onready var boid_scene = preload("res://Boid.tscn")

var window_width = OS.get_window_size().x
var window_height = OS.get_window_size().y

var mouse_position = Vector2()
var mouse_speed = Vector2()

export(int, 0, 1000) var numBoids = 100 # Number of boids spawned at the start (it should be adjustable dynamically).
export(float, 0.0, 9999.0) var visualRange = 75 # Visual range of the boids. Will determine who is a neighbour.

# keepWithinBounds
export(float, 0.0, 9999.0) var keepWithinBoundsMargin = 50 # keepWithinBoundsMargin for out of bounds area.
export(float, -999.0, 999.0) var keepWithinBoundsFactor = 1 # Constant to adjust keepWithinBounds weight. Usually higher than anything else.

# flyTowardsCenter
export(float, -999.0, 999.0) var flyTowardsCenterFactor = 0.005; # Weight for flyTowardsCenter behaviour.

# avoidOthers
export(float, 0, 9999.0) var avoidOthersMinDistance = 20 # The distance to stay away from other boids.
export(float, -999.0, 999.0) var avoidOthersFactor = 0.05 # The rate at which boids correct their position.

# matchVelocity
export(float, -999.0, 999.0) var matchVelocityFactor = 0.05 # Boids adjust their velocity to match others at this rate.

# limitSpeed
export(float, 0, 9999.0) var speedLimit = 5 # Maximum speed of a boid.

# flyTowardsMouse
export(float, -999.0, 999.0) var flyTowardsMouseFactor = 0.005; # adjust velocity by this % # CONST?
export(float, 0, 9999.0) var flyTowardsMouseVisualRange = 200

# avoidMouse
export(float, 0, 9999.0) var avoidMouseMinDistance = 100 # The distance to stay away from other boids # CONST?
export(float, -999.0, 999.0) var avoidMouseFactor = 0.05 # Adjust velocity by this % # CONST?

export(int, 0, 1000) var boidHistoryLength = 50 # Also trail length


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
		
		flyTowardsMouse(boid)
		avoidMouse(boid)
		
		limitSpeed(boid)
		keepWithinBounds(boid)
		
		#Update the position based on the current velocity
		boid.x += boid.dx;
		boid.y += boid.dy;
		boid.history.push_back([boid.x, boid.y])
		if(boid.history.size() > boidHistoryLength): # This will probably give me some issues.
			boid.history.pop_front() # This will probably give me some issues.
		
		drawBoid(boid)


# Constrain a boid to within the window. If it gets too close to an edge,
# nudge it back in and reverse its direction.
func keepWithinBounds(boid):
	if (boid.x < keepWithinBoundsMargin):
		boid.dx += keepWithinBoundsFactor
		
	if (boid.x > window_width - keepWithinBoundsMargin):
		boid.dx -= keepWithinBoundsFactor
		
	if (boid.y < keepWithinBoundsMargin):
		boid.dy += keepWithinBoundsFactor
		
	if (boid.y > window_height - keepWithinBoundsMargin):
		boid.dy -= keepWithinBoundsFactor


# Find the center of mass of the other boids and adjust velocity slightly to
# point towards the center of mass.
func flyTowardsCenter(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
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
		boid.dx += (centerX - boid.x) * flyTowardsCenterFactor
		boid.dy += (centerY - boid.y) * flyTowardsCenterFactor


# Move away from other boids that are too close to avoid colliding
func avoidOthers(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var moveX = 0
	var moveY = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector2(otherBoid.x, otherBoid.y)
		if(otherBoid != boid): # Is it really different as in javascript?
			if(boidPosition.distance_to(otherBoidPosition) < avoidOthersMinDistance):
				moveX += boid.x - otherBoid.x;
				moveY += boid.y - otherBoid.y;
	
	boid.dx += moveX * avoidOthersFactor
	boid.dy += moveY * avoidOthersFactor

# Find the average velocity (speed and direction) of the other boids and
# adjust velocity slightly to match.
func matchVelocity(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var avgDX = 0
	var avgDY = 0
	var numNeighbors = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector2(otherBoid.x, otherBoid.y)
		if(boidPosition.distance_to(otherBoidPosition) < visualRange):
			avgDX += otherBoid.dx
			avgDY += otherBoid.dy
			numNeighbors += 1
	
	if(numNeighbors > 0):
		avgDX = avgDX / numNeighbors
		avgDY = avgDY / numNeighbors
		
		boid.dx += (avgDX - boid.dx) * matchVelocityFactor
		boid.dy += (avgDY - boid.dy) * matchVelocityFactor

# Speed will naturally vary in flocking behavior, but real animals can't go
# arbitrarily fast.
func limitSpeed(boid : Boid):
	var speed = sqrt(boid.dx * boid.dx + boid.dy * boid.dy)
	
	if(speed > speedLimit):
		boid.dx = (boid.dx / speed) * speedLimit
		boid.dy = (boid.dy / speed) * speedLimit

func flyTowardsMouse(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var centerX = 0;
	var centerY = 0;
	var numNeighbors = 0;
	
	if(boidPosition.distance_to(mouse_position) < flyTowardsMouseVisualRange):
		centerX += mouse_position.x
		centerY += mouse_position.y
		numNeighbors += 1
	
	if(numNeighbors > 0):
		centerX = centerX / numNeighbors
		centerY = centerY / numNeighbors
		boid.dx += (centerX - boid.x) * flyTowardsMouseFactor
		boid.dy += (centerY - boid.y) * flyTowardsMouseFactor

func avoidMouse(boid : Boid):
	var boidPosition = Vector2(boid.x, boid.y)
	var moveX = 0
	var moveY = 0
	
	if(boidPosition.distance_to(mouse_position) < avoidMouseMinDistance):
		moveX += boid.x - mouse_position.x;
		moveY += boid.y - mouse_position.y;
	
	boid.dx += moveX * avoidMouseFactor
	boid.dy += moveY * avoidMouseFactor

func drawBoid(boid : Boid):
	boid.position = Vector2(boid.x, boid.y)
	boid.rotation = atan2(boid.dx, -boid.dy)
	#move_to
	#draw_trail
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		mouse_speed = event.speed
