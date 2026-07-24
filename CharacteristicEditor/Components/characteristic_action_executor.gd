extends Node
class_name CharacteristicActionExecutor

@export_category("Configuration")
## Lista das ItemLists que devem ser recarregadas após exclusão ou duplicação
@export var target_item_lists: Array[ItemList] = []

## Uso interno: Detectada automaticamente
var resource_folder: String = ""

## Emitido quando um recurso foi deletado para limpar o formulário ativo
signal resource_deleted(file_id: String)
## Emitido quando a lista precisou ser recarregada
signal list_refreshed

func execute_action(action: String, target_data: Variant) -> void:
	print("[DEBUG Executor] Action requested: ", action, " | Data: ", target_data)
	var target_type = "file"
	var target_path = ""
	
	if typeof(target_data) == TYPE_DICTIONARY:
		target_type = target_data.get("type", "file")
		target_path = target_data.get("id", "") if target_type == "file" else target_data.get("path", "")
	else:
		target_path = str(target_data)
		
	if target_path == "":
		print("[DEBUG Executor] Aborted: target_path is empty.")
		return
	
	if target_type == "file":
		resource_folder = DataManager.find_resource_folder(target_path)
	elif target_type == "dir":
		resource_folder = "characteristics"
		
	if resource_folder == "":
		push_warning("ResourceActionExecutor: Pasta para o recurso '%s' não foi encontrada." % target_path)
		print("[DEBUG Executor] Aborted: resource_folder not found for ", target_path)
		return
		
	print("[DEBUG Executor] Target Type: ", target_type, " | Path: ", target_path, " | Folder: ", resource_folder)
	match action:
		"delete":
			if target_type == "dir":
				print("[DEBUG Executor] Deleting directory via DataManager...")
				DataManager.delete_directory(resource_folder, target_path)
				resource_deleted.emit(target_path)
				list_refreshed.emit()
			else:
				print("[DEBUG Executor] Deleting file via delete_resource()...")
				delete_resource(target_path)
		"duplicate":
			if target_type == "dir":
				push_warning("Aviso: Duplicação de pastas não implementada.")
			else:
				duplicate_resource(target_path)
		"show_in_file_system":
			if target_type == "dir":
				var path = DataManager.BASE_PATH + resource_folder + "/" + target_path
				OS.shell_open(ProjectSettings.globalize_path(path))
			else:
				show_in_file_system(target_path)

func delete_resource(file_id: String) -> void:
	if resource_folder == "":
		print("[DEBUG Executor] delete_resource aborted: no resource_folder.")
		return
		
	DataManager.delete_resource(resource_folder, file_id)
		
	_refresh_target_lists()
	resource_deleted.emit(file_id)

func duplicate_resource(file_id: String) -> void:
	if resource_folder == "":
		return
		
	var original_data = DataManager.load_resource(resource_folder, file_id) as Resource
	if not original_data:
		return
		
	var duplicated_data := original_data.duplicate(true)
	
	# Tentativa genérica de renomear para evitar nomes iguais
	if "characteristic_name" in duplicated_data:
		duplicated_data.characteristic_name += " (Cópia)"
	elif "name" in duplicated_data:
		duplicated_data.name += " (Cópia)"
		
	var base_name = ""
	if "characteristic_name" in duplicated_data:
		base_name = duplicated_data.characteristic_name
	elif "name" in duplicated_data:
		base_name = duplicated_data.name
	else:
		base_name = "Cópia"
		
	var target_folder = file_id.get_base_dir()
	var new_id = DataManager.generate_unique_filename_in_folder(resource_folder, target_folder, base_name)
	if "characteristic_id" in duplicated_data:
		duplicated_data.characteristic_id = new_id
	elif "id" in duplicated_data:
		duplicated_data.id = new_id
		
	if "resource_version" in duplicated_data:
		duplicated_data.resource_version = 1
		
	DataManager.save_resource(duplicated_data, resource_folder, new_id)
	
	_refresh_target_lists()
	
	# Try to select in lists if they are ItemLists (some might fail if not ItemList, but they are expected to be)
	for target_list in target_item_lists:
		if is_instance_valid(target_list) and target_list is ItemList:
			for i in range(target_list.get_item_count()):
				if target_list.get_item_metadata(i) == new_id:
					target_list.select(i)
					target_list.item_selected.emit(i)
					break

func show_in_file_system(file_id: String) -> void:
	if resource_folder == "":
		return
		
	var path = DataManager.get_resource_path(resource_folder, file_id)
	var global_path = ProjectSettings.globalize_path(path)
	OS.shell_open(global_path.get_base_dir())

func _refresh_target_lists() -> void:
	if resource_folder == "": return
	
	var resources := DataManager.list_resources(resource_folder)
	for target_list in target_item_lists:
		if is_instance_valid(target_list):
			target_list.clear()
			for r in resources:
				var idx := target_list.add_item(r)
				target_list.set_item_metadata(idx, r)
				
	list_refreshed.emit()
