class_name MovementController
extends Node

@export var lateral_acceleration: float = 70
@export var max_lateral_velocity: float = 10
@export var vertical_acceleration: float = 200.0
@export var max_vertical_velocity: float = 300.0

var _can_move: bool = true
var _can_jump: bool = true

func get_movement_vector() -> Vector2:
	return Vector2.ZERO


func accelerate_towards(velocity: Vector2, direction: Vector2, delta: float) -> Vector2:
	var new_velocity := velocity
	if not direction.is_zero_approx():
		# Accelerate
		new_velocity.x = move_toward(new_velocity.x, direction.x * max_lateral_velocity, lateral_acceleration * delta)
		new_velocity.y = move_toward(new_velocity.y, direction.y * max_vertical_velocity, vertical_acceleration * delta)
	else:
		# Decelerate
		new_velocity.x = move_toward(new_velocity.x, 0, lateral_acceleration * delta)
		new_velocity.y = move_toward(new_velocity.y, 0, vertical_acceleration * delta)
	return new_velocity


func enable_movement() -> void:
	_can_move = true


func disable_movement() -> void:
	_can_move = false


func enable_jump() -> void:
	_can_jump = true


func disable_jump() -> void:
	_can_jump = false
	
