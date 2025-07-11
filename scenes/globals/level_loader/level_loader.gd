class_name LevelLoaderClass # Global
extends Node

@onready var async_resource_loader: AsyncResourceLoader = %AsyncResourceLoader
@onready var loading_screen: LevelLoadingScreen = %LoadingScreen

var current_level: Level


func _ready() -> void:
	async_resource_loader.resource_loaded.connect(_on_async_level_loaded)
	async_resource_loader.failed_to_load_resource.connect(_on_async_level_load_failed)


func register_level_loaded(level: Level) -> void:
	current_level = level


func get_current_level_file_path() -> StringName:
	return current_level.scene_file_path


func transition_to_level(level_path: StringName) -> void:
	async_resource_loader.load_scene(level_path)
	fade_to_loading_scene()


func fade_to_loading_scene() -> void:
	loading_screen.fade_in_screen()


func fade_to_level_scene() -> void:
	loading_screen.fade_out_screen()


func get_level_load_progress() -> float:
	return async_resource_loader.get_progress()


func _on_async_level_loaded(packed_level: Resource) -> void:
	var level_resource := async_resource_loader.get_resource()
	get_tree().change_scene_to_packed(level_resource)
	fade_to_level_scene()


func _on_async_level_load_failed(level_path: StringName) -> void:
	push_error("Level Loader failed to load level! Level: ", level_path)
