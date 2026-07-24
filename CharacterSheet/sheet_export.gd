class_name SheetExport
# Static helper for exporting CharacterSheetData to PNG or Markdown.

static func export_png(sheet: CharacterSheetData) -> void:
	if not sheet: return
	# Export via SubViewport capture is best done from a dedicated scene.
	# For now, render a TextureRect-based layout and capture it.
	var vp := SubViewport.new()
	vp.size = Vector2i(1240, 1754)  # A4-ish at 150dpi
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE

	var content := _build_png_ui(sheet)
	vp.add_child(content)

	# We need to add viewport to the SceneTree temporarily
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		tree.root.add_child(vp)
		await tree.process_frame
		await tree.process_frame
		var img := vp.get_texture().get_image()
		tree.root.remove_child(vp)
		vp.queue_free()
		var filename := "user://star_stream/exports/%s.png" % sheet.character_name.replace(" ", "_")
		DirAccess.make_dir_recursive_absolute("user://star_stream/exports")
		img.save_png(filename)
		OS.shell_open(ProjectSettings.globalize_path(filename))

static func _build_png_ui(sheet: CharacterSheetData) -> Control:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)

	var _add_lbl := func(parent: Control, text: String, size: int = 14, bold: bool = false) -> Label:
		var l := Label.new()
		l.text = text
		l.add_theme_font_size_override("font_size", size)
		if bold: l.add_theme_font_size_override("font_size", size + 2)
		parent.add_child(l)
		return l

	_add_lbl.call(root, sheet.character_name, 28, true)
	_add_lbl.call(root, "Nível %d | %s | %s | %s" % [
		sheet.level,
		Enums.Archetype.keys()[sheet.archetype],
		sheet.race,
		Enums.Origin.keys()[sheet.origin]
	], 14)

	if sheet.stats:
		var s := sheet.stats
		_add_lbl.call(root, "HP: %d | SAN: %d | Precisão: %d | Vel: %.0f%%" % [
			s.hp_max, s.san_max, s.precision, s.speed_pct], 13)
		_add_lbl.call(root, "Deflexão: %d | Reflexos: %d | Mental: %d | Fortitude: %d" % [
			s.def_deflexao, s.def_reflexos, s.def_mental, s.def_fortitude], 13)

	return root

# Export as a Markdown file
static func export_markdown(sheet: CharacterSheetData) -> void:
	if not sheet: return
	var lines: Array[String] = []
	lines.append("# %s" % sheet.character_name)
	lines.append("")
	lines.append("**Nível:** %d | **Arquétipo:** %s | **Raça:** %s | **Origem:** %s" % [
		sheet.level,
		Enums.Archetype.keys()[sheet.archetype],
		sheet.race,
		Enums.Origin.keys()[sheet.origin]
	])
	lines.append("")
	lines.append("## Atributos")
	if sheet.attributes:
		var a := sheet.attributes
		lines.append("- POD: %d | RES: %d | DEX: %d | INT: %d | PER: %d | DET: %d | LUK: %d" % [
			a.poder, a.resistencia, a.destreza, a.intelecto, a.percepcao, a.determinacao, a.sorte])
	lines.append("")
	lines.append("## Stats Derivados")
	if sheet.stats:
		var s := sheet.stats
		lines.append("- HP Máx: %d | SAN Máx: %d | Energia Máx: %d" % [s.hp_max, s.san_max, s.energy_max])
		lines.append("- Precisão: %d | Vel. Ação: %.0f%%" % [s.precision, s.speed_pct])
		lines.append("- Deflexão: %d | Reflexos: %d | Mental: %d | Fortitude: %d" % [
			s.def_deflexao, s.def_reflexos, s.def_mental, s.def_fortitude])
	lines.append("")
	if not sheet.backstory.is_empty():
		lines.append("## Backstory"); lines.append(sheet.backstory); lines.append("")
	if not sheet.appearance.is_empty():
		lines.append("## Aparência"); lines.append(sheet.appearance); lines.append("")
	if not sheet.personality.is_empty():
		lines.append("## Personalidade"); lines.append(sheet.personality); lines.append("")

	var content := "\n".join(lines)
	var filename := "user://star_stream/exports/%s.md" % sheet.character_name.replace(" ", "_")
	DirAccess.make_dir_recursive_absolute("user://star_stream/exports")
	var file := FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(content)
	OS.shell_open(ProjectSettings.globalize_path(filename))
