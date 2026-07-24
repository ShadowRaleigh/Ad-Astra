extends Control
# Home screen — entry point of the Star Stream app.

const PROFILE_MANAGER := preload("res://Profiles/profile_manager.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.add_theme_constant_override("separation", 24)
	add_child(center)

	var title := Label.new()
	title.text = "★  Star Stream"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Seu companheiro de mesa"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.55, 0.7))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(subtitle)

	center.add_child(HSeparator.new())

	var btn_box := VBoxContainer.new()
	btn_box.add_theme_constant_override("separation", 16)
	center.add_child(btn_box)

	var profiles_btn := _make_button("👤  Gerenciar Perfis", Color(0.28, 0.55, 0.85))
	profiles_btn.pressed.connect(_on_open_profiles)
	btn_box.add_child(profiles_btn)

	var online_btn := _make_button("🌐  Mesa Online", Color(0.25, 0.65, 0.48))
	online_btn.pressed.connect(_on_open_online)
	online_btn.disabled = true  # placeholder until Module 11
	online_btn.tooltip_text = "Disponível no Módulo 11"
	btn_box.add_child(online_btn)

	var version_lbl := Label.new()
	version_lbl.text = "v%s" % ProjectSettings.get_setting("application/config/version", "0.1.0")
	version_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	version_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(version_lbl)

func _make_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(280, 56)
	btn.add_theme_font_size_override("font_size", 18)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", style)
	var hover_style := style.duplicate() as StyleBoxFlat
	hover_style.bg_color = color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover_style)
	return btn

func _on_open_profiles() -> void:
	var manager := PROFILE_MANAGER.new()
	manager.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_parent().add_child(manager)

	# Back button injected into manager
	var back := Button.new()
	back.text = "← Voltar"
	back.pressed.connect(func() -> void:
		manager.queue_free()
	)
	manager.add_child(back)
	manager.move_child(back, 0)

func _on_open_online() -> void:
	pass  # Module 11 placeholder
