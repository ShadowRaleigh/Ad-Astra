extends Node

signal recalculation_started
signal recalculation_finished(affected_count: int)

func run_startup_check() -> void:
	var snapshot := DataManager.load_resource("snapshots", "last_snapshot") as RecalculationSnapshot
	if not snapshot:
		_full_recalculation()
		return
	var changed_chars := _detect_changes(snapshot.characteristic_versions, "characteristics")
	var changed_trees := _detect_changes(snapshot.tree_versions, "trees")
	if changed_chars.size() > 0 or changed_trees.size() > 0:
		_recalculate_affected(changed_chars, changed_trees)
	_save_snapshot()

func _detect_changes(versions: Dictionary, subdir: String) -> Array[String]:
	var changed: Array[String] = []
	for id in DataManager.list_resources(subdir):
		var res := DataManager.load_resource(subdir, id)
		if res and res.get("resource_version") != null:
			if res.resource_version != versions.get(id, -1):
				changed.append(id)
	return changed

func _recalculate_affected(char_ids: Array[String], _tree_ids: Array[String]) -> void:
	recalculation_started.emit()
	var count := 0
	
	# 1. Recalculate basic abilities/trees that modified characteristics touch
	var skill_ids := DataManager.list_resources("abilities")
	for skill_id in skill_ids:
		var skill := DataManager.load_resource("abilities", skill_id) as SkillData
		if skill:
			var needs_recalc := false
			for c_id in skill.source_characteristic_ids:
				if c_id in char_ids:
					needs_recalc = true
					break
			if needs_recalc:
				skill.recalculate_cost()
				DataManager.save_resource(skill, "abilities", skill_id)
				count += 1
				
	# 2. Recalculate characters whose stats might have been affected (optional, but good for completeness)
	var character_ids := DataManager.list_resources("characters")
	for char_id in character_ids:
		var character_data := DataManager.load_resource("characters", char_id) as CharacterSheetData
		if character_data:
			character_data.recalculate_stats()
			DataManager.save_resource(character_data, "characters", char_id)
			count += 1
			
	recalculation_finished.emit(count)

func _full_recalculation() -> void:
	_recalculate_affected([], [])
	_save_snapshot()

func _save_snapshot() -> void:
	var snap := RecalculationSnapshot.new()
	snap.snapshot_time = Time.get_datetime_string_from_system()
	
	# Snapshot all characteristics
	for c_id in DataManager.list_resources("characteristics"):
		var char_data := DataManager.load_resource("characteristics", c_id) as CharacteristicData
		if char_data:
			snap.characteristic_versions[c_id] = char_data.resource_version
			
	# Snapshot all trees
	for t_id in DataManager.list_resources("trees"):
		var tree_data := DataManager.load_resource("trees", t_id) as TreeData
		if tree_data:
			snap.tree_versions[t_id] = tree_data.resource_version
			
	DataManager.save_resource(snap, "snapshots", "last_snapshot")
