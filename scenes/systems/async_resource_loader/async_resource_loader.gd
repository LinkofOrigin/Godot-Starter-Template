class_name AsyncResourceLoader
extends Node

signal resource_loaded(resource: Resource) ## Emitted when a requested resource is loaded and ready for use
signal failed_to_load_resource(path: StringName) ## Emitted when a requested resource failed to load

var _current_load_path: StringName


func get_progress() -> float:
	var progress_ratio := 0.0
	if resource_is_valid(_current_load_path):
		var progress := []
		ResourceLoader.load_threaded_get_status(_current_load_path, progress)
		progress_ratio = progress.pop_back()
	return progress_ratio


func get_status() -> ResourceLoader.ThreadLoadStatus:
	var status := ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	if resource_is_valid(_current_load_path):
		status = ResourceLoader.load_threaded_get_status(_current_load_path)
	return status


func resource_is_valid(path: StringName) -> bool:
	return ResourceLoader.exists(path)


## Attempt to load a resource file asynchronously.
## If it is loaded successfully, a signal will be emitted containing the resource.
func load_scene(scene_path: StringName) -> void:
	if scene_path == null or scene_path.is_empty():
		push_error("Scene path is empty!")
		return
	
	if get_status() == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		push_error("Already loading a scene asynchronously! Please wait or instantiate a new async loader.")
		return
	
	# If we have the resource cached, we'll return that
	_current_load_path = scene_path
	if ResourceLoader.has_cached(_current_load_path):
		# Wait one frame just in case the caller isn't ready to receive the resource immediately
		_retrieve_and_emit_loaded_resource.call_deferred()
	else:
		# Otherwise start async loading
		var error := ResourceLoader.load_threaded_request(_current_load_path)
		if error != OK:
			push_error("Failed to start asynchronously loading resource!")
			return
		set_process(true)


## Retrieve the resource loaded through load_scene().
## If it is already cached, returns the cached resource.
## If it was asynchronously loaded, returns the loaded resource.
## Otherwise will synchronously load the resource and block the thread until
##  it has been loaded, returning that loaded resource when done.
func get_resource() -> Resource:
	var resource: Resource
	if not resource_is_valid(_current_load_path):
		push_error("Can't get resource, invalid path!")
		return null
	
	var cached_resource := ResourceLoader.load(_current_load_path)
	if cached_resource != null:
		resource = cached_resource
	else:
		if get_status() == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			push_warning("About to block thread to retreive resource.")
		var loaded_resource := ResourceLoader.load_threaded_get(_current_load_path)
		if loaded_resource != null:
			resource = loaded_resource
	
	return resource
	

func _retrieve_and_emit_loaded_resource() -> void:
	var resource := get_resource()
	resource_loaded.emit(resource)


# By default, we won't be processing any resources
func _ready() -> void:
	set_process(false)


# If we are actively loading something, check the status each frame
# If it errors out, we'll stop processing. If it succeeds, we'll signal the resource out
func _process(delta: float) -> void:
	var status := get_status()
	
	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			failed_to_load_resource.emit(_current_load_path)
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			_retrieve_and_emit_loaded_resource()
			set_process(false)
