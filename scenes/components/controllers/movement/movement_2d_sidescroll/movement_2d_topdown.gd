class_name MovementController2DTopdown
extends MovementController

# Angle to restrict movement to, in radians
const MOVEMENT_VECTOR_SNAP := Vector2(PI/4, PI/4) # Restricted to 8-directional

@export var target: CharacterBody2D

var _facing_direction: Vector2 = Vector2(0, -1) # Face up for initial state


func _ready() -> void:
	disable_jump()


func _physics_process(delta: float) -> void:
	if _can_move:
		var movement_vector := get_movement_vector()
		move_in_direction(movement_vector, delta)


func move_in_direction(direction: Vector2, delta: float) -> void:
		# Track the direction the character is facing (nice for restricted 4- or 8-direction movement)
		if not direction.is_zero_approx():
			_facing_direction = direction
		
		# TODO: Implement adjustments for moving platforms
		# TODO: Implement adjustments for holes (eg. slipping & falling)
		
		# Set the velocity and move the body
		target.velocity = accelerate_towards(target.velocity, direction, delta)
		target.move_and_slide()
	

func get_restricted_movement_vector() -> Vector2:
	var movement_direction := get_movement_vector()
	return snapped(movement_direction, MOVEMENT_VECTOR_SNAP)


func get_movement_vector() -> Vector2:
	return Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
