extends Node
class_name FileBrowserController

@export var file_list: Tree
@export var new_button: Button
@export var new_folder_button: Button
@export var context_menu_handler: ContextMenuHandler
@export var characteristic_action_executor: CharacteristicActionExecutor

signal file_selected(data: CharacteristicData, file_id: String)
signal file_deleted(file_id: String)
signal new_characteristic_requested

var current_file_id: String = ""
var _expanded_folders: Array[String] = []

func _ready() -> void:
	new_button.pressed.connect(func(): new_characteristic_requested.emit())
	new_folder_button.pressed.connect(_new_folder)
	
	if context_menu_handler and characteristic_action_executor:
		context_menu_handler.action_requested.connect(characteristic_action_executor.execute_action)
		context_menu_handler.action_requested.connect(_on_action_requested)
		characteristic_action_executor.resource_deleted.connect(_on_resource_deleted)
		characteristic_action_executor.list_refreshed.connect(refresh_file_list)
	
	file_list.hide_root = true
	file_list.cell_selected.connect(_on_tree_cell_selected)
	file_list.item_edited.connect(_on_item_edited)
	file_list.gui_input.connect(_on_tree_gui_input)
	file_list.set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)
	
	refresh_file_list()

func deselect_all() -> void:
	if is_instance_valid(file_list):
		file_list.deselect_all()
	current_file_id = ""

## Recarrega completamente a árvore de arquivos de características a partir do sistema de arquivos.
func refresh_file_list() -> void:
	if not is_instance_valid(file_list): return
	
	_expanded_folders.clear()
	if file_list.get_root():
		_save_tree_state(file_list.get_root())
		
	file_list.clear()
	var root := file_list.create_item()
	root.set_text(0, "Características")
	root.set_metadata(0, {"type": "dir", "path": ""})
	var resources_tree := DataManager.list_resources_tree("characteristics")
	_build_tree_recursive(root, resources_tree, "")
	
	_restore_tree_state(root)

## Função auxiliar que constrói os nós da Tree a partir das pastas e arquivos mapeados pelo DataManager.
func _build_tree_recursive(parent_item: TreeItem, tree_dict: Dictionary, current_path: String) -> void:
	var dirs: Dictionary = tree_dict.get("dirs", {})
	for dir_name in dirs.keys():
		var dir_item := parent_item.create_child()
		dir_item.set_text(0, dir_name.capitalize())
		var new_path = current_path + dir_name
		dir_item.set_metadata(0, {"type": "dir", "path": new_path})
		dir_item.collapsed = true
		_build_tree_recursive(dir_item, dirs[dir_name], new_path + "/")
		
	var files: Dictionary = tree_dict.get("files", {})
	for file_name in files.keys():
		var file_id: String = files[file_name]
		var file_item := parent_item.create_child()
		file_item.set_text(0, file_name.get_basename().capitalize())
		file_item.set_metadata(0, {"type": "file", "id": file_id})

## Salva recursivamente o estado atual (expandido/colapsado) das pastas na árvore.
func _save_tree_state(item: TreeItem) -> void:
	if not item: return
	var meta = item.get_metadata(0)
	if meta is Dictionary and meta.get("type") == "dir":
		if not item.collapsed:
			_expanded_folders.append(meta.get("path"))
	var child = item.get_first_child()
	while child:
		_save_tree_state(child)
		child = child.get_next()

## Restaura o estado salvo das pastas na árvore logo após uma atualização de UI.
func _restore_tree_state(item: TreeItem) -> void:
	if not item: return
	var meta = item.get_metadata(0)
	if meta is Dictionary and meta.get("type") == "dir":
		if meta.get("path") in _expanded_folders:
			item.collapsed = false
	var child = item.get_first_child()
	while child:
		_restore_tree_state(child)
		child = child.get_next()

## Seleciona um arquivo da Tree e emite o sinal para carregar no editor principal.
func _on_tree_cell_selected() -> void:
	var selected := file_list.get_selected()
	if not selected: return
	var meta = selected.get_metadata(0)
	if meta is Dictionary and meta.get("type") == "file":
		var file_id = meta.get("id") as String
		var loaded_data := DataManager.load_resource("characteristics", file_id) as CharacteristicData
		if loaded_data:
			current_file_id = file_id
			file_selected.emit(loaded_data, file_id)

## Fornece os dados (lista de arquivos) e o Preview visual para operações de Drag e Drop na árvore.
func _get_drag_data_fw(at_position: Vector2) -> Variant:
	var item := file_list.get_item_at_position(at_position)
	if not item: return null
	var selected_items := []
	var current := file_list.get_next_selected(null)
	while current:
		var meta = current.get_metadata(0)
		if meta is Dictionary and meta.get("type") == "file":
			selected_items.append(meta.get("id"))
		current = file_list.get_next_selected(current)
		
	if selected_items.is_empty(): return null
	var drag_lbl := Label.new()
	drag_lbl.text = "%d Itens Selecionados" % selected_items.size()
	file_list.set_drag_preview(drag_lbl)
	return {"type": "files", "ids": selected_items}

## Valida se o cursor sobre a árvore está em posição válida para soltar os dados arrastados (precisa ser uma pasta).
func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "files":
		var item := file_list.get_item_at_position(at_position)
		if not item: return false
		var meta = item.get_metadata(0)
		if meta is Dictionary and meta.get("type") == "dir":
			return true
	return false

## Completa a ação de Drop iterando sobre os recursos arrastados e movendo-os para a nova pasta de destino.
func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	var item := file_list.get_item_at_position(at_position)
	if not item: return
	var meta = item.get_metadata(0)
	if meta is Dictionary and meta.get("type") == "dir":
		var target_path = meta.get("path") as String
		for file_id in data["ids"]:
			var base_name = file_id.get_file()
			var new_id = target_path + "/" + base_name if target_path != "" else base_name
			if new_id != file_id:
				DataManager.move_resource("characteristics", file_id, new_id)
				if current_file_id == file_id:
					current_file_id = new_id
		refresh_file_list()

## Cria uma nova pasta com numeração incremental segura dentro da pasta pai referenciada pela seleção atual na árvore.
func _new_folder() -> void:
	var target_folder := ""
	var selected := file_list.get_selected()
	if selected:
		var meta = selected.get_metadata(0)
		if meta is Dictionary:
			if meta.get("type") == "dir": target_folder = meta.get("path")
			elif meta.get("type") == "file": target_folder = (meta.get("id") as String).get_base_dir()
				
	var new_folder_base := target_folder + "/Nova Pasta" if target_folder != "" else "Nova Pasta"
	var final_folder := new_folder_base
	var counter := 1
	while DirAccess.dir_exists_absolute(DataManager.BASE_PATH + "characteristics/" + final_folder):
		final_folder = new_folder_base + " " + str(counter)
		counter += 1
		
	DataManager.create_directory("characteristics", final_folder)
	refresh_file_list()

## Avisa o orquestrador caso a característica atual de edição tenha sido deletada externamente.
func _on_resource_deleted(deleted_id: String) -> void:
	if current_file_id == deleted_id or current_file_id.begins_with(deleted_id + "/"):
		file_deleted.emit(deleted_id)

## Interceptador de eventos do mouse em células da lista; abre edição no Duplo-Clique ou menu de contexto no Clique-Direito.
func _on_tree_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
		
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			var item = file_list.get_item_at_position(event.position)
			if item:
				var rect = file_list.get_item_area_rect(item, 0)
				if rect.has_point(event.position):
					item.select(0)
					item.set_editable(0, true)
					file_list.edit_selected(true)
					get_viewport().set_input_as_handled()
		elif event.pressed:
			var item = file_list.get_item_at_position(event.position)
			if not item:
				file_list.deselect_all()
				
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var item = file_list.get_item_at_position(event.position)
		if item:
			var is_selected = false
			var sel = file_list.get_next_selected(null)
			while sel:
				if sel == item:
					is_selected = true
					break
				sel = file_list.get_next_selected(sel)
				
			if not is_selected:
				file_list.deselect_all()
				item.select(0)
				_on_tree_cell_selected()
				
			var meta = item.get_metadata(0)
			if meta is Dictionary:
				if is_instance_valid(context_menu_handler):
					context_menu_handler.show_context_menu(file_list.get_global_mouse_position(), meta)
		else:
			file_list.deselect_all()
			if is_instance_valid(context_menu_handler):
				context_menu_handler.show_context_menu(file_list.get_global_mouse_position(), {"type": "bg"})
				
		get_viewport().set_input_as_handled()

## Mapeia e executa os comandos acionados pelo utilizador via Menu de Contexto (ex: Nova pasta, Renomear).
func _on_action_requested(action: String, _data: Variant) -> void:
	if action == "new_folder":
		_new_folder()
	elif action == "rename":
		var item = file_list.get_selected()
		if item:
			file_list.edit_selected(true)

## Conclui o fluxo de edição de nome diretamente sobre a lista, validando conflitos de diretório ou arquivo antes de salvar pelo DataManager.
func _on_item_edited() -> void:
	var item = file_list.get_edited()
	if not item: return
	
	var new_name = item.get_text(0)
	var safe_name = DataManager.get_safe_filename(new_name)
	var meta = item.get_metadata(0)
	item.set_editable(0, false)
	
	if not meta is Dictionary: return
	
	var type = meta.get("type", "")
	if type == "file":
		var old_id = meta.get("id") as String
		var base_dir = old_id.get_base_dir()
		var new_id = base_dir + "/" + safe_name if base_dir != "" else safe_name
		if old_id != new_id:
			if ResourceLoader.exists(DataManager.BASE_PATH + "characteristics/" + new_id + ".tres") and old_id.to_lower() != new_id.to_lower():
				new_id = DataManager.generate_unique_filename_in_folder("characteristics", base_dir, new_name)
				
			DataManager.move_resource("characteristics", old_id, new_id)
			if current_file_id == old_id:
				current_file_id = new_id
	elif type == "dir":
		var old_path = meta.get("path") as String
		var base_dir = old_path.get_base_dir()
		var new_dir = base_dir + "/" + safe_name if base_dir != "" else safe_name
		if old_path != new_dir:
			var abs_old = DataManager.BASE_PATH + "characteristics/" + old_path
			var abs_new = DataManager.BASE_PATH + "characteristics/" + new_dir
			if DirAccess.dir_exists_absolute(abs_new) and old_path.to_lower() != new_dir.to_lower():
				var counter = 2
				var original_new_dir = new_dir
				while DirAccess.dir_exists_absolute(abs_new):
					new_dir = original_new_dir + "_" + str(counter)
					abs_new = DataManager.BASE_PATH + "characteristics/" + new_dir
					counter += 1
					
			DirAccess.rename_absolute(abs_old, abs_new)
			
	refresh_file_list()
