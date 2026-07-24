class_name RuleScanner extends RefCounted

static func scan_folder(folder_path: String) -> Array[Resource]:
	var results: Array[Resource] = []
	var dir = DirAccess.open(folder_path)
	
	if not dir:
		push_error("RuleScanner: Failed to open directory ", folder_path)
		return results
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# Ignore non-gdscript files
		if file_name.ends_with(".gd"):
			var full_path = folder_path + "/" + file_name
			var script = load(full_path) as GDScript
			if script:
				# Instantiate to extract name and description for UI
				var inst = script.new()
				if inst is CharacteristicRestriction or inst is CharacteristicModifier:
					results.append(inst)
		file_name = dir.get_next()
		
	return results
