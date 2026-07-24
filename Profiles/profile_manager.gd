extends Control
# Profile Manager — lists, searches, paginates, and organises CharacterSheetData cards.

const PROFILE_CARD := preload("res://Profiles/profile_card.gd")
const SHEET_EDITOR := preload("res://CharacterSheet/sheet_editor.gd")
const FOLDER_TREE := preload("res://Profiles/folder_tree.gd")
const SheetExport := preload("res://CharacterSheet/sheet_export.gd")

const CARDS_PER_PAGE := 10

var _current_folder: String = ""    # empty = root
var _search_query: String = ""
var _filter_type: String = "Todos"  # "Todos", "CHARACTER", "CREATURE"
var _current_page: int = 0

var _all_ids: Array[String] = []
var _filtered_ids: Array[String] = []

# UI nodes
var _search_edit: LineEdit
var _filter_opt: OptionButton
var _new_char_btn: Button
var _new_creature_btn: Button
var _card_grid: GridContainer
var _page_label: Label
var _prev_btn: Button
var _next_btn: Button
var _folder_tree: Node   # folder_tree.gd instance
var _context_menu: PopupMenu
var _context_target_id: String = ""

# Editor overlay
var _editor_overlay: Control = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hbox)

	# Sidebar
	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size = Vector2(180, 0)
	hbox.add_child(sidebar)

	_folder_tree = FOLDER_TREE.new()
	_folder_tree.size_flags_vertical = SIZE_EXPAND_FILL
	_folder_tree.folder_selected.connect(_on_folder_selected)
	sidebar.add_child(_folder_tree)

	# Main area
	var main_vbox := VBoxContainer.new()
	main_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(main_vbox)

	# Toolbar
	var toolbar := HBoxContainer.new()
	main_vbox.add_child(toolbar)

	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = "Buscar por nome..."
	_search_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_search_edit.text_changed.connect(_on_search_changed)
	toolbar.add_child(_search_edit)

	_filter_opt = OptionButton.new()
	_filter_opt.add_item("Todos"); _filter_opt.add_item("Personagens"); _filter_opt.add_item("Criaturas")
	_filter_opt.item_selected.connect(_on_filter_changed)
	toolbar.add_child(_filter_opt)

	_new_char_btn = Button.new()
	_new_char_btn.text = "+ Personagem"
	_new_char_btn.pressed.connect(func() -> void: _open_new_sheet(Enums.SheetType.CHARACTER))
	toolbar.add_child(_new_char_btn)

	_new_creature_btn = Button.new()
	_new_creature_btn.text = "+ Criatura"
	_new_creature_btn.pressed.connect(func() -> void: _open_new_sheet(Enums.SheetType.CREATURE))
	toolbar.add_child(_new_creature_btn)

	# Card grid
	var grid_scroll := ScrollContainer.new()
	grid_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	main_vbox.add_child(grid_scroll)

	_card_grid = GridContainer.new()
	_card_grid.columns = 5
	_card_grid.add_theme_constant_override("h_separation", 12)
	_card_grid.add_theme_constant_override("v_separation", 12)
	_card_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	grid_scroll.add_child(_card_grid)

	# Pagination
	var pag_row := HBoxContainer.new()
	main_vbox.add_child(pag_row)

	_prev_btn = Button.new(); _prev_btn.text = "← Anterior"
	_prev_btn.pressed.connect(func() -> void: _go_page(-1))
	pag_row.add_child(_prev_btn)

	_page_label = Label.new()
	_page_label.size_flags_horizontal = SIZE_EXPAND_FILL
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pag_row.add_child(_page_label)

	_next_btn = Button.new(); _next_btn.text = "Próximo →"
	_next_btn.pressed.connect(func() -> void: _go_page(1))
	pag_row.add_child(_next_btn)

	# Context menu
	_context_menu = PopupMenu.new()
	_context_menu.add_item("Editar",     0)
	_context_menu.add_item("Duplicar",   1)
	_context_menu.add_separator()
	_context_menu.add_item("Favoritar",  2)
	_context_menu.add_item("Exportar PNG", 3)
	_context_menu.add_item("Exportar MD",  4)
	_context_menu.add_separator()
	_context_menu.add_item("Deletar",    5)
	_context_menu.id_pressed.connect(_on_context_action)
	add_child(_context_menu)

	_refresh_all()

func _refresh_all() -> void:
	_all_ids = DataManager.list_resources("characters")
	_apply_filter()

func _apply_filter() -> void:
	_filtered_ids.clear()
	for char_id in _all_ids:
		var res := DataManager.load_resource("characters", char_id)
		if not res or not res is CharacterSheetData: continue
		var sheet := res as CharacterSheetData
		# Folder filter
		if _current_folder and not char_id.begins_with(_current_folder + "/"): continue
		# Type filter
		match _filter_type:
			"Personagens":
				if sheet.sheet_type != Enums.SheetType.CHARACTER: continue
			"Criaturas":
				if sheet.sheet_type != Enums.SheetType.CREATURE: continue
		# Search filter
		if not _search_query.is_empty():
			if not sheet.character_name.to_lower().contains(_search_query.to_lower()): continue
		_filtered_ids.append(char_id)
	_current_page = 0
	_render_page()

func _render_page() -> void:
	for child in _card_grid.get_children():
		child.queue_free()

	var total_pages: int = max(1, ceili(float(_filtered_ids.size()) / float(CARDS_PER_PAGE)))
	_current_page = clampi(_current_page, 0, total_pages - 1)
	_page_label.text = "Página %d / %d" % [_current_page + 1, total_pages]
	_prev_btn.disabled = _current_page == 0
	_next_btn.disabled = _current_page >= total_pages - 1

	var start := _current_page * CARDS_PER_PAGE
	var end := mini(start + CARDS_PER_PAGE, _filtered_ids.size())
	for i in range(start, end):
		var char_id: String = _filtered_ids[i]
		var sheet := DataManager.load_resource("characters", char_id) as CharacterSheetData
		if not sheet: continue
		var card := PROFILE_CARD.new()
		_card_grid.add_child(card)
		card.load_card(sheet, char_id)
		card.card_clicked.connect(_on_card_clicked)
		card.card_right_clicked.connect(_on_card_right_clicked)

func _go_page(delta: int) -> void:
	_current_page += delta
	_render_page()

func _on_search_changed(text: String) -> void:
	_search_query = text
	_apply_filter()

func _on_filter_changed(index: int) -> void:
	var opts := ["Todos", "Personagens", "Criaturas"]
	_filter_type = opts[index]
	_apply_filter()

func _on_folder_selected(folder: String) -> void:
	_current_folder = folder
	_apply_filter()

func _on_card_clicked(char_id: String) -> void:
	_open_edit_sheet(char_id)

func _on_card_right_clicked(char_id: String) -> void:
	_context_target_id = char_id
	_context_menu.popup_on_parent(Rect2(get_global_mouse_position(), Vector2.ZERO))

func _on_context_action(action_id: int) -> void:
	var sheet := DataManager.load_resource("characters", _context_target_id) as CharacterSheetData
	if not sheet: return
	match action_id:
		0: _open_edit_sheet(_context_target_id)
		1:
			var new_id := DataManager.generate_unique_filename("characters", sheet.character_name + "_copia")
			DataManager.save_resource(sheet.duplicate(true), "characters", new_id)
			_refresh_all()
		2:
			sheet.custom_fields["favorite"] = not sheet.custom_fields.get("favorite", false)
			DataManager.save_resource(sheet, "characters", _context_target_id)
			_refresh_all()
		3: SheetExport.export_png(sheet)
		4: SheetExport.export_markdown(sheet)
		5:
			DataManager.delete_resource("characters", _context_target_id)
			_refresh_all()

func _open_new_sheet(type: Enums.SheetType) -> void:
	var editor := _create_editor_overlay()
	editor.new_sheet(type)

func _open_edit_sheet(char_id: String) -> void:
	var sheet := DataManager.load_resource("characters", char_id) as CharacterSheetData
	if not sheet: return
	var editor := _create_editor_overlay()
	editor.load_sheet(sheet)

func _create_editor_overlay() -> Node:
	if _editor_overlay:
		_editor_overlay.queue_free()
	var editor := SHEET_EDITOR.new()
	editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	editor.sheet_saved.connect(func(_d: CharacterSheetData) -> void:
		_editor_overlay.queue_free()
		_editor_overlay = null
		_refresh_all()
	)
	add_child(editor)
	_editor_overlay = editor
	# Back button to close without saving
	var back := Button.new()
	back.text = "← Voltar"
	back.pressed.connect(func() -> void:
		_editor_overlay.queue_free()
		_editor_overlay = null
	)
	editor.add_child(back)
	editor.move_child(back, 0)
	return editor
