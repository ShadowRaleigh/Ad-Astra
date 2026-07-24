extends Control
# Folder tree sidebar for the Profile Manager.
# Scans characters/ subdirectories and lets user select/create/delete folders.

signal folder_selected(folder_path: String)

var _tree: Tree
var _new_folder_btn: Button
var _delete_folder_btn: Button
var _current_folder: String = ""

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Pastas"
	lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(lbl)

	_tree = Tree.new()
	_tree.hide_root = true
	_tree.size_flags_vertical = SIZE_EXPAND_FILL
	_tree.item_selected.connect(_on_item_selected)
	vbox.add_child(_tree)

	var btn_row := HBoxContainer.new()
	vbox.add_child(btn_row)

	_new_folder_btn = Button.new()
	_new_folder_btn.text = "+ Pasta"
	_new_folder_btn.pressed.connect(_on_new_folder)
	btn_row.add_child(_new_folder_btn)

	_delete_folder_btn = Button.new()
	_delete_folder_btn.text = "✕"
	_delete_folder_btn.pressed.connect(_on_delete_folder)
	btn_row.add_child(_delete_folder_btn)

	_refresh_tree()

func _refresh_tree() -> void:
	_tree.clear()
	var root := _tree.create_item()

	# "Todos" root
	var all_item := _tree.create_item(root)
	all_item.set_text(0, "📁 Todos os Personagens")
	all_item.set_metadata(0, "")

	# Scan subdirs
	var tree_data := DataManager.list_resources_tree("characters")
	_populate_tree_item(root, tree_data["dirs"], "")

func _populate_tree_item(parent: TreeItem, dirs: Dictionary, prefix: String) -> void:
	for dir_name in dirs.keys():
		var item := _tree.create_item(parent)
		item.set_text(0, "📂 " + dir_name)
		var full_path: String = (prefix + "/" + dir_name) if prefix else dir_name
		item.set_metadata(0, full_path)
		_populate_tree_item(item, dirs[dir_name]["dirs"], full_path)

func _on_item_selected() -> void:
	var item := _tree.get_selected()
	if item:
		_current_folder = item.get_metadata(0)
		emit_signal("folder_selected", _current_folder)

func _on_new_folder() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Nova Pasta"
	var le := LineEdit.new()
	le.placeholder_text = "Nome da pasta"
	dialog.add_child(le)
	dialog.confirmed.connect(func() -> void:
		var folder_name := le.text.strip_edges()
		if folder_name.is_empty(): return
		var folder_path := (_current_folder + "/" + folder_name) if _current_folder else folder_name
		DataManager.create_directory("characters", folder_path)
		_refresh_tree()
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()

func _on_delete_folder() -> void:
	if _current_folder.is_empty(): return
	var confirm := ConfirmationDialog.new()
	confirm.dialog_text = "Deletar pasta '%s' e todo seu conteúdo?" % _current_folder
	confirm.confirmed.connect(func() -> void:
		DataManager.delete_directory("characters", _current_folder)
		_current_folder = ""
		_refresh_tree()
		emit_signal("folder_selected", "")
		confirm.queue_free()
	)
	add_child(confirm)
	confirm.popup_centered()
