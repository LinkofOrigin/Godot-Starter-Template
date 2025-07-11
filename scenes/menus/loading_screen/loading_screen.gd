class_name LevelLoadingScreen
extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var fade_container: PanelContainer = %FadeContainer
@onready var loading_content_container: VBoxContainer = %LoadingContentContainer
@onready var progress_text: Label = %"Progress Text"
@onready var progress_bar: ProgressBar = %ProgressBar


func fade_in_screen() -> void:
	show()
	animation_player.set_process(true)
	animation_player.play("fade_in_screen")
	set_process(true)


func fade_out_screen() -> void:
	animation_player.play("fade_out_screen")
	set_process(false)
	await animation_player.animation_finished
	animation_player.set_process(false)
	hide()


func update_progress_for_level() -> void:
	var progress: float = LevelLoader.get_level_load_progress()
	set_progress_amount(progress)


func set_progress_amount(progress: float) -> void:
	progress_bar.value = progress


func _ready() -> void:
	hide()
	fade_container.self_modulate.a = 0
	loading_content_container.self_modulate.a = 0
	set_process(false)
	animation_player.set_process(false)


func _process(delta: float) -> void:
	update_progress_for_level()
