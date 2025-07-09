class_name MovementController2DSidescroll
extends MovementController

@export var target: CharacterBody2D


func _physics_process(delta: float) -> void:
	if _can_move:
		var movement_vector := get_movement_vector()
		move_in_direction(movement_vector, delta)


func move_in_direction(direction: Vector2, delta: float) -> void:
	var new_velocity := target.velocity
	var grav_adjust := target.get_gravity() * delta
	
	new_velocity = accelerate_towards(new_velocity, direction + grav_adjust, delta)
	
	# Account for a potential jump
	if _can_jump:
		new_velocity.y = adjust_for_jump(new_velocity.y)
	
	target.velocity = new_velocity
	target.move_and_slide()


func adjust_for_jump(up_velocity: float) -> float:
	var jump_velocity := up_velocity
	if Input.is_action_just_pressed("Jump") and target.is_on_floor():
		jump_velocity = max_vertical_velocity * -1
	return jump_velocity


func get_movement_vector() -> Vector2:
	return Vector2(Input.get_axis("Move Left", "Move Right"), 0)
