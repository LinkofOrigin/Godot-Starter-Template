class_name Level
extends Node


func _ready() -> void:
	LevelLoader.register_level_loaded(self)
