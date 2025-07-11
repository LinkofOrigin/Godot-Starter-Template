extends Control

const scene_paths := [
	'res://scenes/levels/test/test_3d/level_3d.tscn',
	'res://scenes/levels/test/test_2d_topdown/level_2d_topdown.tscn',
	'res://scenes/levels/test/test_2d_sidescroll/level_2d_sidescroll.tscn',
]

@onready var prev_scene: Button = %PrevScene
@onready var next_scene: Button = %NextScene

var _current_scene_index: int = 0


func _ready() -> void:
	prev_scene.pressed.connect(_on_previous_scene_pressed)
	next_scene.pressed.connect(_on_next_scene_pressed)


func _on_previous_scene_pressed() -> void:
	var current_level_path := LevelLoader.get_current_level_file_path()
	var current_level_index := scene_paths.find(current_level_path)
	current_level_index -= 1
	if current_level_index < 0:
		current_level_index = scene_paths.size() - 1
	
	LevelLoader.transition_to_level(scene_paths[current_level_index])
	


func _on_next_scene_pressed() -> void:
	var current_level_path := LevelLoader.get_current_level_file_path()
	var current_level_index := scene_paths.find(current_level_path)
	current_level_index += 1
	if current_level_index >= scene_paths.size():
		current_level_index = 0
	LevelLoader.transition_to_level(scene_paths[current_level_index])


func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event.
