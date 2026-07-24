extends Control
# Main tabbed character/creature sheet editor.
# Usage: call load_sheet(data) to populate, or set new_sheet_type to start fresh.

signal sheet_saved(data: CharacterSheetData)

const ATTR_SPINNER := preload("res://CharacterSheet/Components/attribute_spinner.gd")
const STAT_DISPLAY := preload("res://CharacterSheet/Components/stat_display.gd")
const TEXT_FIELD := preload("res://CharacterSheet/Components/text_field_editor.gd")
const LIST_EDITOR := preload("res://CharacterSheet/Components/list_editor.gd")
const INVENTORY_PANEL := preload("res://Inventory/inventory_panel.gd")
const SheetExport := preload("res://CharacterSheet/sheet_export.gd")

var _sheet: CharacterSheetData = null
var _dirty: bool = false

# Tabs
var _tabs: TabContainer
var _save_btn: Button
var _export_png_btn: Button
var _export_md_btn: Button
var _error_label: Label
var _title_label: Label

# Identity tab widgets
var _name_edit: LineEdit
var _level_spin: SpinBox
var _race_edit: LineEdit
var _archetype_opt: OptionButton
var _origin_opt: OptionButton
var _class_edit: LineEdit
var _history_edit: LineEdit
var _portrait_edit: LineEdit

# Attributes tab widgets
var _attr_spinners: Dictionary = {}  # attribute_name -> AttributeSpinner node

# Stats tab widgets
var _hp_base_spin: SpinBox
var _energy_base_spin: SpinBox
var _stat_displays: Dictionary = {}  # stat_name -> StatDisplay node

# Narrative tab
var _appearance_field: Node
var _backstory_field: Node
var _affiliations_field: Node
var _objectives_field: Node
var _personality_field: Node
var _fears_field: Node

# Progression tab
var _subclasses_list: Node
var _subraces_list: Node
var _titles_list: Node
var _proficiencies_list: Node
var _skills_list: Node
var _talents_list: Node

# Equipment/Inventory tab
var _inventory_panel: Node

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	vbox.add_child(header)

	_title_label = Label.new()
	_title_label.text = "Nova Ficha"
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(_title_label)

	_error_label = Label.new()
	_error_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	_error_label.visible = false
	header.add_child(_error_label)

	_save_btn = Button.new()
	_save_btn.text = "💾 Salvar"
	_save_btn.pressed.connect(_on_save)
	header.add_child(_save_btn)

	_export_png_btn = Button.new()
	_export_png_btn.text = "📷 PNG"
	_export_png_btn.pressed.connect(_on_export_png)
	header.add_child(_export_png_btn)

	_export_md_btn = Button.new()
	_export_md_btn.text = "📄 MD"
	_export_md_btn.pressed.connect(_on_export_md)
	header.add_child(_export_md_btn)

	# Tabs
	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(_tabs)

	_build_identity_tab()
	_build_attributes_tab()
	_build_stats_tab()
	_build_narrative_tab()
	_build_progression_tab()
	_build_equipment_tab()

# ─── TAB BUILDERS ────────────────────────────────────────────────────────────

func _build_identity_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Identidade"
	_tabs.add_child(scroll)
	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation", 8)
	form.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(form)

	_name_edit = _field(form, "Nome *", LineEdit.new())
	_name_edit.text_changed.connect(func(_t: String) -> void: _mark_dirty())

	_level_spin = SpinBox.new(); _level_spin.min_value = 1; _level_spin.max_value = 100
	_field(form, "Nível", _level_spin)
	_level_spin.value_changed.connect(func(_v: float) -> void: _on_recalculate())

	_race_edit = _field(form, "Raça *", LineEdit.new())
	_race_edit.text_changed.connect(func(_t: String) -> void: _mark_dirty())

	_archetype_opt = OptionButton.new()
	for key in Enums.Archetype.keys():
		_archetype_opt.add_item(key)
	_field(form, "Arquétipo", _archetype_opt)
	_archetype_opt.item_selected.connect(func(_i: int) -> void: _on_recalculate())

	_origin_opt = OptionButton.new()
	for key in Enums.Origin.keys():
		_origin_opt.add_item(key)
	_field(form, "Origem", _origin_opt)
	_origin_opt.item_selected.connect(func(_i: int) -> void: _on_recalculate())

	_class_edit = _field(form, "Classe Customizada", LineEdit.new())
	_history_edit = _field(form, "Histórico *", LineEdit.new())
	_portrait_edit = _field(form, "Retrato (caminho)", LineEdit.new())

func _build_attributes_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Atributos"
	_tabs.add_child(scroll)
	var form := VBoxContainer.new()
	form.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(form)

	var attr_info := {
		"poder": "POD — +3% dano/cura, +2 Fortitude",
		"resistencia": "RES — ±5% HP, +2 Fortitude",
		"destreza": "DEX — ±2% Vel. Ação, +2 Reflexos",
		"intelecto": "INT — +3% Duração/AoE, +2 Mental",
		"percepcao": "PER — +1 Precisão, +2 Reflexos",
		"determinacao": "DET — +1 Concentração, +2 Mental, +1 Deflex.",
		"sorte": "LUK — Limiar de crítico/falha no d100 (max 20)",
	}
	for attr_key in attr_info:
		var spinner := ATTR_SPINNER.new()
		spinner.attribute_name = attr_key.to_upper().substr(0, 3)
		spinner.bonus_hint = attr_info[attr_key]
		spinner.min_value = 1
		spinner.max_value = 30
		spinner.value_changed.connect(func(_name: String, _val: int) -> void: _on_attr_changed(attr_key, _val))
		_attr_spinners[attr_key] = spinner
		form.add_child(spinner)

func _build_stats_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Stats Derivados"
	_tabs.add_child(scroll)
	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation", 10)
	form.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(form)

	# Editable base values
	var base_section := Label.new()
	base_section.text = "Valores Base (Editáveis)"
	base_section.add_theme_font_size_override("font_size", 13)
	form.add_child(base_section)

	var hp_row := HBoxContainer.new()
	form.add_child(hp_row)
	var hp_lbl := Label.new(); hp_lbl.text = "HP Base:"; hp_lbl.custom_minimum_size = Vector2(100, 0)
	hp_row.add_child(hp_lbl)
	_hp_base_spin = SpinBox.new(); _hp_base_spin.min_value = 0; _hp_base_spin.max_value = 99999
	_hp_base_spin.suffix = "  (0 = auto)"
	_hp_base_spin.value_changed.connect(func(_v: float) -> void: _on_recalculate())
	hp_row.add_child(_hp_base_spin)

	var energy_row := HBoxContainer.new()
	form.add_child(energy_row)
	var energy_lbl := Label.new(); energy_lbl.text = "Energia Base:"; energy_lbl.custom_minimum_size = Vector2(100, 0)
	energy_row.add_child(energy_lbl)
	_energy_base_spin = SpinBox.new(); _energy_base_spin.min_value = 0; _energy_base_spin.max_value = 99999
	_energy_base_spin.suffix = "  (0 = auto)"
	_energy_base_spin.value_changed.connect(func(_v: float) -> void: _on_recalculate())
	energy_row.add_child(_energy_base_spin)

	form.add_child(HSeparator.new())

	var derived_section := Label.new()
	derived_section.text = "Totais Calculados (inclui bônus de equipamento)"
	derived_section.add_theme_font_size_override("font_size", 13)
	form.add_child(derived_section)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 8)
	form.add_child(grid)

	var stat_names := ["HP", "SAN", "Energia", "Precisão", "Vel. Ação",
					   "Deflexão", "Reflexos", "Mental", "Fortitude"]
	for sname in stat_names:
		var sd := STAT_DISPLAY.new()
		sd.stat_label = sname
		grid.add_child(sd)
		_stat_displays[sname] = sd

func _build_narrative_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Narrativa"
	_tabs.add_child(scroll)
	var form := VBoxContainer.new()
	form.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(form)

	_appearance_field = _text_section(form, "Aparência", 4)
	_backstory_field = _text_section(form, "Backstory", 6)
	_affiliations_field = _text_section(form, "Afiliações", 3)
	_objectives_field = _text_section(form, "Objetivos", 3)
	_personality_field = _text_section(form, "Personalidade", 3)
	_fears_field = _text_section(form, "Medos & Fraquezas", 3)

func _build_progression_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Progressão"
	_tabs.add_child(scroll)
	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation", 12)
	form.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(form)

	_subclasses_list = _list_section(form, "Subclasses")
	_subraces_list = _list_section(form, "Sub-Raças")
	_titles_list = _list_section(form, "Títulos (máx 3 ativos)", 3)
	_proficiencies_list = _list_section(form, "Proficiências")
	_skills_list = _list_section(form, "Perícias")
	_talents_list = _list_section(form, "Talentos")

func _build_equipment_tab() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = "Equipamento"
	_tabs.add_child(vbox)

	_inventory_panel = INVENTORY_PANEL.new()
	_inventory_panel.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(_inventory_panel)

# ─── HELPERS ─────────────────────────────────────────────────────────────────

func _field(parent: Control, label: String, widget: Control) -> Control:
	var row := VBoxContainer.new()
	parent.add_child(row)
	var lbl := Label.new()
	lbl.text = label
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	row.add_child(lbl)
	widget.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(widget)
	return widget

func _text_section(parent: Control, label: String, lines: int = 3) -> Node:
	var tf := TEXT_FIELD.new()
	tf.field_label = label
	tf.min_lines = lines
	tf.text_changed.connect(func(_t: String) -> void: _mark_dirty())
	parent.add_child(tf)
	return tf

func _list_section(parent: Control, label: String, max_items: int = -1) -> Node:
	var le := LIST_EDITOR.new()
	le.field_label = label
	le.max_items = max_items
	le.list_changed.connect(func(_l: Array) -> void: _mark_dirty())
	parent.add_child(le)
	return le

# ─── DATA BINDING ─────────────────────────────────────────────────────────────

func load_sheet(data: CharacterSheetData) -> void:
	_sheet = data
	_dirty = false
	_populate_ui()

func new_sheet(type: Enums.SheetType = Enums.SheetType.CHARACTER) -> void:
	_sheet = CharacterSheetData.new()
	_sheet.sheet_type = type
	_sheet.character_id = DataManager.generate_id()
	_sheet.created_at = Time.get_datetime_string_from_system()
	_dirty = false
	_populate_ui()

func _populate_ui() -> void:
	if not _sheet: return
	_title_label.text = _sheet.character_name if not _sheet.character_name.is_empty() else "Nova Ficha"

	# Identity
	_name_edit.text = _sheet.character_name
	_level_spin.value = _sheet.level
	_race_edit.text = _sheet.race
	_archetype_opt.select(_sheet.archetype)
	_origin_opt.select(_sheet.origin)
	_class_edit.text = _sheet.class_name_custom
	_history_edit.text = _sheet.history
	_portrait_edit.text = _sheet.portrait_path

	# Attributes
	var attrs := _sheet.attributes
	if attrs:
		_safe_set_spinner("poder", attrs.poder)
		_safe_set_spinner("resistencia", attrs.resistencia)
		_safe_set_spinner("destreza", attrs.destreza)
		_safe_set_spinner("intelecto", attrs.intelecto)
		_safe_set_spinner("percepcao", attrs.percepcao)
		_safe_set_spinner("determinacao", attrs.determinacao)
		_safe_set_spinner("sorte", attrs.sorte)

	# Base overrides
	if _sheet.stats:
		_hp_base_spin.value = _sheet.stats.hp_base
		_energy_base_spin.value = _sheet.stats.energy_base

	# Narrative
	_appearance_field.set_text(_sheet.appearance)
	_backstory_field.set_text(_sheet.backstory)
	_affiliations_field.set_text(_sheet.affiliations)
	_objectives_field.set_text(_sheet.objectives)
	_personality_field.set_text(_sheet.personality)
	_fears_field.set_text(_sheet.fears)

	# Progression
	_subclasses_list.set_items(_sheet.subclasses)
	_subraces_list.set_items(_sheet.subraces)
	_titles_list.set_items(_sheet.titles)
	_proficiencies_list.set_items(_sheet.proficiencies)
	_skills_list.set_items(_sheet.skills)
	_talents_list.set_items(_sheet.talents)

	# Inventory
	if _sheet.inventory:
		_inventory_panel.load_inventory(_sheet.inventory)

	_refresh_stats_display()

func _safe_set_spinner(key: String, value: int) -> void:
	if _attr_spinners.has(key):
		_attr_spinners[key].set_value(value)

func _on_attr_changed(attr_key: String, value: int) -> void:
	if not _sheet or not _sheet.attributes: return
	_sheet.attributes.set(attr_key, value)
	_on_recalculate()

func _on_recalculate() -> void:
	if not _sheet: return
	_sheet.level = int(_level_spin.value)
	_sheet.archetype = _archetype_opt.selected as Enums.Archetype
	_sheet.origin = _origin_opt.selected as Enums.Origin
	if _sheet.stats:
		_sheet.stats.hp_base = int(_hp_base_spin.value)
		_sheet.stats.energy_base = int(_energy_base_spin.value)
	_sheet.recalculate_stats()
	_refresh_stats_display()
	_mark_dirty()

func _refresh_stats_display() -> void:
	if not _sheet or not _sheet.stats: return
	var totals := _sheet.get_total_stats()

	_safe_set_stat("HP", totals.get("hp_max", 0), 0)
	_safe_set_stat("SAN", totals.get("san_max", 0), 0)

	# Energy label uses origin-appropriate name
	var energy_name_map: Dictionary = {
		Enums.Origin.TECNOLOGICA: "Bateria",
		Enums.Origin.MISTICA: "Mana",
		Enums.Origin.MARCIAL: "Qi",
		Enums.Origin.TRANSCENDENTAL: "PE"
	}
	var energy_name: String = energy_name_map.get(_sheet.origin, "Energia")
	if _stat_displays.has("Energia"):
		_stat_displays["Energia"].stat_label = energy_name
	_safe_set_stat("Energia", totals.get("energy_max", 0), 0)

	_safe_set_stat("Precisão", totals.get("precision", 0), 0)
	_safe_set_stat("Vel. Ação", int(totals.get("speed_pct", 100.0)), 0)
	_safe_set_stat("Deflexão", totals.get("def_deflexao", 0), 0)
	_safe_set_stat("Reflexos", totals.get("def_reflexos", 0), 0)
	_safe_set_stat("Mental", totals.get("def_mental", 0), 0)
	_safe_set_stat("Fortitude", totals.get("def_fortitude", 0), 0)

func _safe_set_stat(key: String, value: int, mod: int) -> void:
	if _stat_displays.has(key):
		_stat_displays[key].set_stat(key, value, mod)

func _mark_dirty() -> void:
	_dirty = true

# ─── SAVE / EXPORT ────────────────────────────────────────────────────────────

func _collect_data_from_ui() -> void:
	if not _sheet: return
	_sheet.character_name = _name_edit.text.strip_edges()
	_sheet.level = int(_level_spin.value)
	_sheet.race = _race_edit.text.strip_edges()
	_sheet.archetype = _archetype_opt.selected as Enums.Archetype
	_sheet.origin = _origin_opt.selected as Enums.Origin
	_sheet.class_name_custom = _class_edit.text.strip_edges()
	_sheet.history = _history_edit.text.strip_edges()
	_sheet.portrait_path = _portrait_edit.text.strip_edges()
	_sheet.appearance = _appearance_field.get_text()
	_sheet.backstory = _backstory_field.get_text()
	_sheet.affiliations = _affiliations_field.get_text()
	_sheet.objectives = _objectives_field.get_text()
	_sheet.personality = _personality_field.get_text()
	_sheet.fears = _fears_field.get_text()
	_sheet.subclasses = _subclasses_list.get_items()
	_sheet.subraces = _subraces_list.get_items()
	_sheet.titles = _titles_list.get_items()
	_sheet.proficiencies = _proficiencies_list.get_items()
	_sheet.skills = _skills_list.get_items()
	_sheet.talents = _talents_list.get_items()
	_sheet.updated_at = Time.get_datetime_string_from_system()
	_title_label.text = _sheet.character_name if not _sheet.character_name.is_empty() else "Nova Ficha"

func _on_save() -> void:
	_collect_data_from_ui()
	if not _sheet: return
	var errors := _sheet.validate()
	if not errors.is_empty():
		_error_label.text = errors[0]
		_error_label.visible = true
		return
	_error_label.visible = false
	var filename := DataManager.generate_unique_filename("characters", _sheet.character_name)
	var err := DataManager.save_resource(_sheet, "characters", filename)
	if err == OK:
		_dirty = false
		emit_signal("sheet_saved", _sheet)
	else:
		_error_label.text = "Erro ao salvar: %s" % error_string(err)
		_error_label.visible = true

func _on_export_png() -> void:
	SheetExport.export_png(_sheet)

func _on_export_md() -> void:
	SheetExport.export_markdown(_sheet)
