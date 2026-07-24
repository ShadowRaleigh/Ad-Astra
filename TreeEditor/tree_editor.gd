extends Control

@onready var graph_edit: GraphEdit = %GraphEdit
@onready var tree_name_input: LineEdit = %TreeNameInput
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var new_node_button: Button = %NewNodeButton
@onready var validate_button: Button = %ValidateButton
@onready var organize_button: Button = %OrganizeButton

@onready var char_picker: Window = %CharacteristicPicker
@onready var picker_list: Tree = %PickerList
@onready var picker_cancel: Button = %PickerCancel
@onready var picker_select: Button = %PickerSelect

@onready var load_dialog: Window = %LoadDialog
@onready var load_list: Tree = %LoadList
@onready var load_cancel: Button = %LoadCancel
@onready var load_confirm: Button = %LoadConfirm

@onready var notif_panel: PanelContainer = %NotificationPanel
@onready var notif_title: Label = %NotifTitleLabel
@onready var notif_path: Label = %NotifPathLabel
@onready var notif_timer: Timer = %NotifTimer

var current_tree: TreeData = null
var current_tree_id: String = ""
var _node_counter: int = 0
var _requesting_node: GraphNode = null
var context_menu: PopupMenu
var load_context_menu: PopupMenu

var _expanded_folders: Array[String] = []

func _ready() -> void:
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.delete_nodes_request.connect(_on_delete_nodes)
	if graph_edit.has_signal("duplicate_nodes_request"):
		graph_edit.duplicate_nodes_request.connect(_duplicate_selected_nodes)
	
	new_node_button.pressed.connect(_add_new_node)
	save_button.pressed.connect(_save_tree)
	validate_button.pressed.connect(_validate_tree)
	organize_button.pressed.connect(_organize_layout)
	load_button.pressed.connect(_on_load_button_pressed)
	
	picker_cancel.pressed.connect(func(): char_picker.hide())
	picker_select.pressed.connect(_on_picker_select)
	char_picker.close_requested.connect(func(): char_picker.hide())
	picker_list.item_activated.connect(_on_picker_select)
	
	load_cancel.pressed.connect(func(): load_dialog.hide())
	load_confirm.pressed.connect(_on_load_confirm)
	load_dialog.close_requested.connect(func(): load_dialog.hide())
	load_list.item_activated.connect(_on_load_confirm)
	notif_timer.timeout.connect(_hide_notification)
	
	load_list.set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)
	load_list.gui_input.connect(_on_load_list_gui_input)
	load_list.item_edited.connect(_on_load_item_edited)

	context_menu = PopupMenu.new()
	add_child(context_menu)
	context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	
	load_context_menu = PopupMenu.new()
	add_child(load_context_menu)
	load_context_menu.add_item("Nova Pasta", 0)
	load_context_menu.add_item("Renomear", 1)
	load_context_menu.add_item("Excluir", 2)
	load_context_menu.id_pressed.connect(_on_load_context_menu_id_pressed)
	graph_edit.popup_request.connect(_on_graph_edit_popup_request)

	_new_tree()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("duplicate"):
		var focus_owner = get_viewport().gui_get_focus_owner()
		var is_text_editing = focus_owner is LineEdit or focus_owner is TextEdit
		if not is_text_editing:
			_duplicate_selected_nodes()
			get_viewport().set_input_as_handled()

func _new_tree() -> void:
	current_tree = TreeData.new()
	current_tree_id = DataManager.generate_id()
	current_tree.tree_id = current_tree_id
	tree_name_input.text = ""
	_node_counter = 0
	_clear_graph()

func _add_new_node() -> void:
	var node_data := TreeNodeData.new()
	node_data.node_id = "node_%d_%d" % [Time.get_ticks_msec(), _node_counter]
	_node_counter += 1
	current_tree.nodes.append(node_data)
	_create_graph_node(node_data)

func _create_graph_node(data: TreeNodeData) -> GraphNode:
	var gn := preload("res://TreeEditor/tree_graph_node.tscn").instantiate()
	gn.name = data.node_id
	gn.position_offset = Vector2(data.grid_position) * 200
	gn.node_data = data
	gn.assign_characteristic_requested.connect(_on_assign_char_requested)
	graph_edit.add_child(gn)
	return gn

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	var gn := graph_edit.get_node(NodePath(String(from_node))) as GraphNode
	if gn:
		gn.node_data.connections_out.append(String(to_node))

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	var gn := graph_edit.get_node(NodePath(String(from_node))) as GraphNode
	if gn:
		gn.node_data.connections_out.erase(String(to_node))

func _on_delete_nodes(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var gn := graph_edit.get_node(NodePath(String(node_name))) as GraphNode
		if gn:
			current_tree.nodes.erase(gn.node_data)
			gn.queue_free()

func _on_assign_char_requested(node: GraphNode) -> void:
	_requesting_node = node
	picker_list.clear()
	var root := picker_list.create_item()
	var chars := DataManager.list_resources("characteristics")
	var folder_items = {"": root}
	
	for c_id in chars:
		var char_data := DataManager.load_resource("characteristics", c_id) as CharacteristicData
		if char_data:
			var folder = c_id.get_base_dir()
			var current_path = ""
			var parent_item = root
			
			if folder != "":
				var p_parts = folder.split("/")
				for p in p_parts:
					var next_path = current_path + "/" + p if current_path != "" else p
					if not folder_items.has(next_path):
						var f_item = picker_list.create_item(parent_item)
						f_item.set_text(0, p.capitalize())
						f_item.set_selectable(0, false)
						folder_items[next_path] = f_item
					parent_item = folder_items[next_path]
					current_path = next_path
					
			var item := picker_list.create_item(parent_item)
			item.set_text(0, char_data.characteristic_name.capitalize())
			item.set_metadata(0, char_data)
			
	char_picker.popup_centered()

func _on_picker_select() -> void:
	var selected = picker_list.get_selected()
	if selected and _requesting_node != null:
		var char_data = selected.get_metadata(0)
		if char_data is CharacteristicData:
			_requesting_node.node_data.characteristic = char_data
			_requesting_node._update_display()
			char_picker.hide()

func _save_tree() -> void:
	current_tree.tree_name = tree_name_input.text
	_sync_positions_from_graph()
	
	var validation_errors = current_tree.validate()
	var is_valid = validation_errors.is_empty()
	
	current_tree.resource_version += 1
	var save_err = DataManager.save_resource(current_tree, "trees", current_tree_id)
	
	if save_err == OK:
		var path = DataManager.get_resource_path("trees", current_tree_id)
		_show_notification(is_valid, path)
		print("Tree saved: ", path)
	else:
		_show_error_notification("Erro ao salvar a árvore!")

func _show_notification(is_valid: bool, path: String) -> void:
	notif_panel.visible = true
	notif_panel.modulate.a = 1.0
	
	notif_path.text = "Caminho: " + path
	if is_valid:
		notif_title.text = "Árvore Salva com Sucesso!"
		notif_title.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		notif_title.text = "Árvore Salva (Com Erros)!"
		notif_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
		
	notif_timer.start()

func _show_error_notification(msg: String) -> void:
	notif_panel.visible = true
	notif_panel.modulate.a = 1.0
	notif_title.text = msg
	notif_title.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	notif_path.text = ""
	notif_timer.start()

func _hide_notification() -> void:
	var tween = create_tween()
	tween.tween_property(notif_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): notif_panel.visible = false)

func _sync_positions_from_graph() -> void:
	for node_data in current_tree.nodes:
		var gn := graph_edit.get_node_or_null(NodePath(node_data.node_id)) as GraphNode
		if gn:
			node_data.grid_position = Vector2i(gn.position_offset / 200)

func _clear_graph() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			graph_edit.remove_child(child)
			child.queue_free()

func _validate_tree() -> void:
	var errors := current_tree.validate()
	if errors.is_empty():
		print("Árvore válida!")
	else:
		for err in errors:
			print("Erro de Validação: ", err)

func _on_load_button_pressed() -> void:
	_refresh_load_list()
	load_dialog.popup_centered()

func _refresh_load_list() -> void:
	_expanded_folders.clear()
	if load_list.get_root():
		_save_tree_state(load_list.get_root())
		
	load_list.clear()
	var root := load_list.create_item()
	root.set_text(0, "Árvores")
	root.set_metadata(0, {"type": "dir", "path": ""})
	var resources_tree := DataManager.list_resources_tree("trees")
	_build_tree_recursive(root, resources_tree, "")
	
	_restore_tree_state(root)

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
		var display_name = file_name.get_basename().capitalize()
		var tree_data := DataManager.load_resource("trees", file_id) as TreeData
		if tree_data and tree_data.tree_name != "":
			display_name = tree_data.tree_name.capitalize()
			
		file_item.set_text(0, display_name)
		file_item.set_metadata(0, {"type": "file", "id": file_id})

func _on_load_confirm() -> void:
	var selected = load_list.get_selected()
	if selected:
		var meta = selected.get_metadata(0)
		if meta is Dictionary and meta.get("type") == "file":
			var t_id = meta.get("id") as String
			var tree_data := DataManager.load_resource("trees", t_id) as TreeData
			if tree_data:
				_load_tree_into_editor(tree_data, t_id)
				load_dialog.hide()

func _get_drag_data_fw(at_position: Vector2) -> Variant:
	var item := load_list.get_item_at_position(at_position)
	if not item: return null
	var selected_items := []
	var current := load_list.get_next_selected(null)
	while current:
		var meta = current.get_metadata(0)
		if meta is Dictionary and meta.get("type") == "file":
			selected_items.append(meta.get("id"))
		current = load_list.get_next_selected(current)
		
	if selected_items.is_empty(): return null
	var drag_lbl := Label.new()
	drag_lbl.text = "%d Itens Selecionados" % selected_items.size()
	load_list.set_drag_preview(drag_lbl)
	return {"type": "files", "ids": selected_items}

func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "files":
		var item := load_list.get_item_at_position(at_position)
		if not item: return false
		var meta = item.get_metadata(0)
		if meta is Dictionary and meta.get("type") == "dir":
			return true
	return false

func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	var item := load_list.get_item_at_position(at_position)
	if not item: return
	var meta = item.get_metadata(0)
	if meta is Dictionary and meta.get("type") == "dir":
		var target_path = meta.get("path") as String
		for file_id in data["ids"]:
			var base_name = file_id.get_file()
			var new_id = target_path + "/" + base_name if target_path != "" else base_name
			if new_id != file_id:
				DataManager.move_resource("trees", file_id, new_id)
				if current_tree_id == file_id:
					current_tree_id = new_id
		_refresh_load_list()

func _on_load_list_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
		
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var item = load_list.get_item_at_position(event.position)
			if not item:
				load_list.deselect_all()
				
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var item = load_list.get_item_at_position(event.position)
		if item:
			var is_selected = false
			var sel = load_list.get_next_selected(null)
			while sel:
				if sel == item:
					is_selected = true
					break
				sel = load_list.get_next_selected(sel)
				
			if not is_selected:
				load_list.deselect_all()
				item.select(0)
				
			load_context_menu.position = Vector2i(DisplayServer.mouse_get_position())
			load_context_menu.popup()
		else:
			load_list.deselect_all()
			load_context_menu.position = Vector2i(DisplayServer.mouse_get_position())
			load_context_menu.popup()
				
		get_viewport().set_input_as_handled()

func _on_load_item_edited() -> void:
	var item = load_list.get_edited()
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
			if ResourceLoader.exists(DataManager.BASE_PATH + "trees/" + new_id + ".tres") and old_id.to_lower() != new_id.to_lower():
				new_id = DataManager.generate_unique_filename_in_folder("trees", base_dir, new_name)
				
			DataManager.move_resource("trees", old_id, new_id)
			if current_tree_id == old_id:
				current_tree_id = new_id
	elif type == "dir":
		var old_path = meta.get("path") as String
		var base_dir = old_path.get_base_dir()
		var new_dir = base_dir + "/" + safe_name if base_dir != "" else safe_name
		if old_path != new_dir:
			var abs_old = DataManager.BASE_PATH + "trees/" + old_path
			var abs_new = DataManager.BASE_PATH + "trees/" + new_dir
			if DirAccess.dir_exists_absolute(abs_new) and old_path.to_lower() != new_dir.to_lower():
				var counter = 2
				var original_new_dir = new_dir
				while DirAccess.dir_exists_absolute(abs_new):
					new_dir = original_new_dir + "_" + str(counter)
					abs_new = DataManager.BASE_PATH + "trees/" + new_dir
					counter += 1
					
			DirAccess.rename_absolute(abs_old, abs_new)
			
	call_deferred("_refresh_load_list")

func _on_load_context_menu_id_pressed(id: int) -> void:
	match id:
		0: # Nova Pasta
			var target_folder := ""
			var selected = load_list.get_selected()
			if selected:
				var meta = selected.get_metadata(0)
				if meta is Dictionary:
					if meta.get("type") == "dir": target_folder = meta.get("path")
					elif meta.get("type") == "file": target_folder = (meta.get("id") as String).get_base_dir()
						
			var new_folder_base := target_folder + "/Nova Pasta" if target_folder != "" else "Nova Pasta"
			var final_folder := new_folder_base
			var counter := 1
			while DirAccess.dir_exists_absolute(DataManager.BASE_PATH + "trees/" + final_folder):
				final_folder = new_folder_base + " " + str(counter)
				counter += 1
				
			DataManager.create_directory("trees", final_folder)
			_refresh_load_list()
		1: # Renomear
			var item = load_list.get_selected()
			if item:
				load_list.edit_selected(true)
		2: # Excluir
			var item = load_list.get_selected()
			if item:
				var meta = item.get_metadata(0)
				if meta is Dictionary:
					if meta.get("type") == "file":
						DataManager.delete_resource("trees", meta.get("id"))
					elif meta.get("type") == "dir":
						DataManager.delete_directory("trees", meta.get("path"))
					_refresh_load_list()

func _load_tree_into_editor(tree_data: TreeData, t_id: String) -> void:
	_clear_graph()
	current_tree = tree_data
	current_tree_id = t_id
	tree_name_input.text = current_tree.tree_name
	
	# Recreate nodes
	for nd in current_tree.nodes:
		_create_graph_node(nd)
		
	# Await 1 frame so nodes process layout before connecting
	await get_tree().process_frame
	
	# Recreate connections
	for nd in current_tree.nodes:
		for conn_out in nd.connections_out:
			graph_edit.connect_node(nd.node_id, 0, conn_out, 0)

func _on_graph_edit_popup_request(pos: Vector2) -> void:
	context_menu.clear()
	
	var global_mouse = graph_edit.get_global_mouse_position()
	var clicked_node: GraphNode = null
	var children = graph_edit.get_children()
	for i in range(children.size() - 1, -1, -1):
		var child = children[i]
		if child is GraphNode:
			if child.get_global_rect().has_point(global_mouse):
				clicked_node = child
				break
				
	if clicked_node and not clicked_node.selected:
		for child in graph_edit.get_children():
			if child is GraphNode:
				child.selected = false
		clicked_node.selected = true
	
	var selected_nodes = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			selected_nodes.append(child)
			
	if selected_nodes.is_empty():
		context_menu.add_item("Criar Novo Nó", 0)
	else:
		context_menu.add_item("Duplicar Nó(s)", 1)
		context_menu.add_item("Limpar Nó(s)", 4)
		context_menu.add_item("Remover Conexões", 2)
		context_menu.add_item("Excluir Nó(s)", 3)
		
	context_menu.position = Vector2i(graph_edit.get_screen_position()) + Vector2i(pos)
	context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
	match id:
		0: # Criar Novo Nó
			_add_new_node_at_mouse()
		1: # Duplicar Nó(s)
			_duplicate_selected_nodes()
		2: # Remover Conexões
			_remove_connections_of_selected()
		3: # Excluir Nó(s)
			_delete_selected_nodes()
		4: # Limpar Nó(s)
			_clear_selected_nodes()

func _clear_selected_nodes() -> void:
	_remove_connections_of_selected()
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			child.node_data.characteristic = null
			child.node_data.floor_index = 0
			child._update_display()

func _add_new_node_at_mouse() -> void:
	var node_data := TreeNodeData.new()
	node_data.node_id = "node_%d_%d" % [Time.get_ticks_msec(), _node_counter]
	_node_counter += 1
	
	var local_mouse = graph_edit.get_local_mouse_position()
	var grid_pos = (local_mouse + graph_edit.scroll_offset) / graph_edit.zoom / 200.0
	node_data.grid_position = Vector2i(grid_pos.x, grid_pos.y)
	
	current_tree.nodes.append(node_data)
	_create_graph_node(node_data)

func _duplicate_selected_nodes() -> void:
	var selected_nodes = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			selected_nodes.append(child)
			child.selected = false
			
	for node in selected_nodes:
		var nd: TreeNodeData = node.node_data
		var new_data := TreeNodeData.new()
		new_data.node_id = "node_%d_%d" % [Time.get_ticks_msec(), _node_counter]
		_node_counter += 1
		new_data.grid_position = nd.grid_position + Vector2i(1, 1)
		new_data.characteristic = nd.characteristic
		new_data.floor_index = nd.floor_index
		
		current_tree.nodes.append(new_data)
		var new_gn = _create_graph_node(new_data)
		new_gn.selected = true

func _remove_connections_of_selected() -> void:
	var selected_names = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			selected_names.append(String(child.name))
			
	var conns = graph_edit.get_connection_list()
	for conn in conns:
		if String(conn.from_node) in selected_names or String(conn.to_node) in selected_names:
			_on_disconnection_request(conn.from_node, conn.from_port, conn.to_node, conn.to_port)

func _delete_selected_nodes() -> void:
	var selected_names: Array[StringName] = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			selected_names.append(child.name)
			
	if selected_names.size() > 0:
		_on_delete_nodes(selected_names)

func _organize_layout() -> void:
	if current_tree == null or current_tree.nodes.is_empty():
		return
		
	var layers: Dictionary = {}
	var min_floor: int = 0
	var max_floor: int = 0
	
	for node_data in current_tree.nodes:
		var f: int = node_data.floor_index
		if not layers.has(f):
			layers[f] = []
		layers[f].append(node_data)
		min_floor = mini(min_floor, f)
		max_floor = maxi(max_floor, f)
		
	if layers.is_empty():
		return
		
	var get_in_neighbors = func(n_id: String) -> Array[String]:
		var in_ns: Array[String] = []
		for other in current_tree.nodes:
			if n_id in other.connections_out:
				in_ns.append(other.node_id)
		return in_ns

	var LAYER_SPACING_X: float = 400.0
	var NODE_SPACING_Y: float = 200.0
	
	# Posicionamento inicial: distribuídos uniformemente no grid 200x200
	for floor_idx in layers.keys():
		var layer_nodes: Array = layers[floor_idx]
		layer_nodes.sort_custom(func(a, b): return a.node_id < b.node_id)
		var start_y: float = - floori((layer_nodes.size() - 1) / 2.0) * NODE_SPACING_Y
		for i in range(layer_nodes.size()):
			var gn: GraphNode = graph_edit.get_node_or_null(NodePath(layer_nodes[i].node_id))
			if gn:
				gn.position_offset = Vector2(floor_idx * LAYER_SPACING_X, start_y + i * NODE_SPACING_Y)
	
	# Passes baricêntricos: forward + backward
	var passes: int = 4
	for _p in range(passes):
		# Forward: esquerda → direita (filho acompanha pai)
		for floor_idx in range(min_floor + 1, max_floor + 1):
			if not layers.has(floor_idx): continue
			var layer_nodes: Array = layers[floor_idx]
			
			var barycenters: Dictionary = {}
			for n_data in layer_nodes:
				var in_ns = get_in_neighbors.call(n_data.node_id)
				var sum_y := 0.0
				var count := 0
				for in_id in in_ns:
					var gn_in: GraphNode = graph_edit.get_node_or_null(NodePath(in_id))
					if gn_in:
						sum_y += gn_in.position_offset.y
						count += 1
				var gn_self: GraphNode = graph_edit.get_node_or_null(NodePath(n_data.node_id))
				barycenters[n_data.node_id] = sum_y / count if count > 0 else (gn_self.position_offset.y if gn_self else 0.0)
				
			layer_nodes.sort_custom(func(a, b): return barycenters[a.node_id] < barycenters[b.node_id])
			_place_layer(layer_nodes, barycenters, NODE_SPACING_Y)

		# Backward: direita → esquerda (pai acompanha filho)
		for floor_idx in range(max_floor - 1, min_floor - 1, -1):
			if not layers.has(floor_idx): continue
			var layer_nodes: Array = layers[floor_idx]
			
			var barycenters: Dictionary = {}
			for n_data in layer_nodes:
				var sum_y := 0.0
				var count := 0
				for out_id in n_data.connections_out:
					var gn_out: GraphNode = graph_edit.get_node_or_null(NodePath(out_id))
					if gn_out:
						sum_y += gn_out.position_offset.y
						count += 1
				var gn_self: GraphNode = graph_edit.get_node_or_null(NodePath(n_data.node_id))
				barycenters[n_data.node_id] = sum_y / count if count > 0 else (gn_self.position_offset.y if gn_self else 0.0)
				
			layer_nodes.sort_custom(func(a, b): return barycenters[a.node_id] < barycenters[b.node_id])
			_place_layer(layer_nodes, barycenters, NODE_SPACING_Y)

	_sync_positions_from_graph()

# Posiciona os nós de uma camada centrados ao redor da média dos baricentros,
# mantendo o espaçamento uniforme entre eles.
func _place_layer(layer_nodes: Array, barycenters: Dictionary, spacing: float) -> void:
	var count: int = layer_nodes.size()
	if count == 0:
		return
	
	# Âncora: média dos baricentros → o grupo "flutua" para a posição ideal
	var avg_bc: float = 0.0
	for n_data in layer_nodes:
		avg_bc += barycenters[n_data.node_id]
	avg_bc /= count
	
	# Snap the start_y to the 200px grid to prevent truncation data loss on save
	var snapped_avg_bc = roundi(avg_bc / spacing) * spacing
	var start_y: float = snapped_avg_bc - floori((count - 1) / 2.0) * spacing
	
	for i in range(count):
		var gn: GraphNode = graph_edit.get_node_or_null(NodePath(layer_nodes[i].node_id))
		if gn:
			gn.position_offset.y = start_y + i * spacing
