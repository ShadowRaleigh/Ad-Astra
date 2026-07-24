extends Node

const BASE_PATH := "user://star_stream/"
const BACKUP_INTERVAL := 300.0 # 5 minutes

var _backup_timer: Timer

func _ready() -> void:
	_ensure_directories()
	_start_backup_timer()

func _ensure_directories() -> void:
	var dirs := ["characters", "items", "trees", "characteristics",
				 "abilities", "maps", "combat_logs", "table_states",
				 "backups", "snapshots"]
	for dir in dirs:
		if not DirAccess.dir_exists_absolute(BASE_PATH + dir):
			DirAccess.make_dir_recursive_absolute(BASE_PATH + dir)

func save_resource(resource: Resource, subdirectory: String, filename: String) -> Error:
	var path := BASE_PATH + subdirectory + "/" + filename + ".tres"
	return ResourceSaver.save(resource, path)

func load_resource(subdirectory: String, filename: String) -> Resource:
	var path := BASE_PATH + subdirectory + "/" + filename + ".tres"
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path)
	return null

func list_resources(subdirectory: String) -> Array[String]:
	var results: Array[String] = []
	var results_tree = list_resources_tree(subdirectory)
	_flatten_tree(results_tree, "", results)
	return results

func _flatten_tree(tree_dict: Dictionary, current_path: String, out_array: Array[String]) -> void:
	for file_id in tree_dict["files"].values():
		out_array.append(file_id)
	for dir_name in tree_dict["dirs"].keys():
		_flatten_tree(tree_dict["dirs"][dir_name], current_path + dir_name + "/", out_array)

func list_resources_tree(subdirectory: String) -> Dictionary:
	var root_path := BASE_PATH + subdirectory
	_ensure_directories() # Ensure it exists just in case
	return _scan_dir_recursive(root_path, "")

func _scan_dir_recursive(abs_path: String, rel_path: String) -> Dictionary:
	var result := {"type": "dir", "files": {}, "dirs": {}}
	var dir := DirAccess.open(abs_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				if dir.current_is_dir():
					var sub_rel = rel_path + file_name + "/"
					result["dirs"][file_name] = _scan_dir_recursive(abs_path + "/" + file_name, sub_rel)
				elif file_name.ends_with(".tres"):
					var base_id := file_name.get_basename()
					var file_id := rel_path + base_id
					result["files"][file_name] = file_id
			file_name = dir.get_next()
	return result

func create_directory(subdirectory: String, folder_internal_path: String) -> Error:
	var path := BASE_PATH + subdirectory + "/" + folder_internal_path
	return DirAccess.make_dir_recursive_absolute(path)

func move_resource(subdirectory: String, old_id: String, new_id: String) -> Error:
	var old_path := BASE_PATH + subdirectory + "/" + old_id + ".tres"
	var new_path := BASE_PATH + subdirectory + "/" + new_id + ".tres"
	var base_dir := new_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(base_dir):
		DirAccess.make_dir_recursive_absolute(base_dir)
	return DirAccess.rename_absolute(old_path, new_path)

func delete_resource(subdirectory: String, filename: String) -> Error:
	return DirAccess.remove_absolute(BASE_PATH + subdirectory + "/" + filename + ".tres")

func delete_directory(subdirectory: String, folder_internal_path: String) -> Error:
	var path := BASE_PATH + subdirectory + "/" + folder_internal_path
	print("[DEBUG DataManager] Attempting to delete directory: ", path)
	var err = _remove_dir_recursive(path)
	print("[DEBUG DataManager] Finished deleting directory. Final error code: ", err)
	return err

func _remove_dir_recursive(path: String) -> Error:
	var dir := DirAccess.open(path)
	if not dir:
		print("[DEBUG DataManager] Failed to open DirAccess for path: ", path)
		return ERR_FILE_NOT_FOUND
		
	var items = []
	var is_dirs = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			items.append(file_name)
			is_dirs.append(dir.current_is_dir())
		file_name = dir.get_next()
	dir.list_dir_end()
	
	for i in range(items.size()):
		var full_path = path + "/" + items[i]
		if is_dirs[i]:
			print("[DEBUG DataManager] Recursively entering subdirectory: ", full_path)
			_remove_dir_recursive(full_path)
		else:
			var file_err = DirAccess.remove_absolute(full_path)
			print("[DEBUG DataManager] Deleting file: ", full_path, " | Result: ", file_err)
			
	var dir_err = DirAccess.remove_absolute(path)
	print("[DEBUG DataManager] Deleting folder: ", path, " | Result: ", dir_err)
	return dir_err

func get_resource_path(subdirectory: String, filename: String) -> String:
	return BASE_PATH + subdirectory + "/" + filename + ".tres"

func find_resource_folder(file_id: String) -> String:
	var dirs := ["characters", "items", "trees", "characteristics", "abilities", "maps", "combat_logs", "table_states"]
	for dir in dirs:
		var path: String = BASE_PATH + dir + "/" + file_id + ".tres"
		if ResourceLoader.exists(path):
			return dir
	return ""

func duplicate_resource(subdirectory: String, src: String, dst: String) -> Error:
	var res := load_resource(subdirectory, src)
	if res:
		return save_resource(res.duplicate(true), subdirectory, dst)
	return ERR_FILE_NOT_FOUND

func create_backup() -> void:
	var ts := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var backup_dir := BASE_PATH + "backups/backup_" + ts
	DirAccess.make_dir_recursive_absolute(backup_dir)
	
	var dirs_to_copy: Array[String] = ["characters", "items", "trees", "characteristics", "abilities", "maps", "combat_logs", "table_states", "snapshots"]
	
	for subdir: String in dirs_to_copy:
		var src_path: String = BASE_PATH + subdir
		var dst_path: String = backup_dir + "/" + subdir
		if DirAccess.dir_exists_absolute(src_path):
			DirAccess.make_dir_recursive_absolute(dst_path)
			var dir := DirAccess.open(src_path)
			if dir:
				dir.list_dir_begin()
				var file_name := dir.get_next()
				while file_name != "":
					if not dir.current_is_dir():
						DirAccess.copy_absolute(src_path + "/" + file_name, dst_path + "/" + file_name)
					file_name = dir.get_next()

func _start_backup_timer() -> void:
	_backup_timer = Timer.new()
	_backup_timer.wait_time = BACKUP_INTERVAL
	_backup_timer.autostart = true
	_backup_timer.timeout.connect(create_backup)
	add_child(_backup_timer)

func generate_id() -> String:
	return str(randi()) + "_" + str(Time.get_ticks_msec())

func get_safe_filename(text: String) -> String:
	var safe := text.to_lower().strip_edges()
	safe = safe.replace(" ", "_").replace("-", "_")
	
	var regex := RegEx.new()
	regex.compile("[\\\\/:*?\"<>|.,';\\[\\]\\{\\}!@#$%^&()=+]")
	safe = regex.sub(safe, "", true)
	
	# Fallback if the name is entirely invalid characters
	if safe == "":
		safe = "unnamed_resource"
		
	return safe

func generate_unique_filename(subdirectory: String, base_name: String) -> String:
	return generate_unique_filename_in_folder(subdirectory, "", base_name)

func generate_unique_filename_in_folder(subdirectory: String, folder_path: String, base_name: String) -> String:
	var safe_base := get_safe_filename(base_name)
	var full_prefix := folder_path + "/" if folder_path != "" else ""
	var path := BASE_PATH + subdirectory + "/" + full_prefix + safe_base + ".tres"
	
	if folder_path != "" and not DirAccess.dir_exists_absolute(BASE_PATH + subdirectory + "/" + folder_path):
		DirAccess.make_dir_recursive_absolute(BASE_PATH + subdirectory + "/" + folder_path)
	
	if not ResourceLoader.exists(path):
		return full_prefix + safe_base
		
	var counter := 2
	while true:
		var new_name := safe_base + "_" + str(counter)
		var new_path := BASE_PATH + subdirectory + "/" + full_prefix + new_name + ".tres"
		if not ResourceLoader.exists(new_path):
			return full_prefix + new_name
		counter += 1
		
	return full_prefix + safe_base
