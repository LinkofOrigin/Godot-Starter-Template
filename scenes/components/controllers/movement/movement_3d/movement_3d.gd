class_name MovementController3D
extends MovementController

const MAX_CAMERA_UP: float = PI / 2.0
const MIN_CAMERA_DOWN: float = PI / -2.0

@export var target: CharacterBody3D
@export var camera: Camera3D
@export_range(1, 100, 1) var camera_speed: float = 30
@export var inverted_camera_y: bool = true

var _can_move_camera: bool = true

func _ready() -> void:
	if target == null:
		target = get_parent() # Assume the parent is the intended target if not explicitly set


func _physics_process(delta: float) -> void:
	if _can_move:
		var movement_vector := get_movement_vector()
		move_in_direction(movement_vector, delta)


func move_in_direction(direction: Vector2, delta: float) -> void:
	handle_camera(delta) # This will handle camera inputs separately to alter the target body
	
	var new_velocity := target.velocity
	new_velocity.y += (target.get_gravity() * delta).y
	direction = direction.rotated(target.rotation.y * -1) # Account for the camera facing
	
	# Accelerate and map to the proper axes
	var adjusted_velocity := accelerate_towards(Vector2(new_velocity.x, new_velocity.z), direction, delta)
	new_velocity.x = adjusted_velocity.x
	new_velocity.z = adjusted_velocity.y
	
	# Account for a potential jump
	if _can_jump:
		new_velocity.y = adjust_for_jump(new_velocity.y)
	
	# Set the velocity and move
	target.velocity = new_velocity
	target.move_and_slide()


func handle_camera(delta: float) -> void:
	if _can_move_camera:
		var new_rotation := get_camera_movement_vector(delta)
		if not new_rotation.is_zero_approx():
			#print("rotate: ", new_rotation)
			pass
		
		_apply_look_rotation(new_rotation.x, new_rotation.y)


func get_movement_vector() -> Vector2:
	return _get_raw_movement_vector().rotated(camera.rotation.y * -1)


func _apply_look_rotation(horizontal_rotation: float, vertical_rotation: float) -> void:
	target.rotate_y(horizontal_rotation)
	camera.rotate_x(vertical_rotation)
	
	target.rotation.y = fmod(target.rotation.y, 2 * PI) # Don't let the rotation go up/down forever and hit a number storage boundary
	camera.rotation.x = clamp(camera.rotation.x, MIN_CAMERA_DOWN, MAX_CAMERA_UP) # Prevent looking past straight up or down


func get_camera_movement_vector(delta: float) -> Vector2:
	var camera_vector := get_camera_vector()
	camera_vector *= camera_speed * delta / 10 # Scale the speed down to make the variable input more user friendly
	return camera_vector


func get_camera_vector() -> Vector2:
	# Note that this vector is a weird order because we map each joystick axis to a different axis in 3D space
	var joystick_camera_vector := Input.get_vector(
			"Camera Left",
			"Camera Right",
			"Camera Up",
			"Camera Down"
			) * -1
	if inverted_camera_y:
		joystick_camera_vector.y *= -1
	
	return joystick_camera_vector


func adjust_for_jump(up_velocity: float) -> float:
	# TODO: Implement double-jump
	var jump_velocity := up_velocity
	if Input.is_action_just_pressed("Jump") and target.is_on_floor():
		jump_velocity = max_vertical_velocity
	return jump_velocity


func _get_raw_movement_vector() -> Vector2:
	return Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")


func get_mouse_motion_vector_from_event(event: InputEventMouseMotion) -> Vector2:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return Vector2(0,0)
	return Vector2(event.screen_relative.x, event.screen_relative.y) * -1 * 0.003


func _unhandled_input(event: InputEvent) -> void:
	# This handles mouse movements to control the camera since we can't do that as easily in the pure physics process
	if event is InputEventMouseMotion:
		var mouse_motion := get_mouse_motion_vector_from_event(event as InputEventMouseMotion)
		_apply_look_rotation(mouse_motion.x, mouse_motion.y)
