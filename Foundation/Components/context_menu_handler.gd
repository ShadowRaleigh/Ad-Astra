extends Node
class_name ContextMenuHandler

@export var menu_scene: PackedScene

var context_menu: Control = null
var context_menu_data: Variant = null

signal action_requested(action: String, data: Variant)

func show_context_menu(pos: Vector2, data: Variant = null) -> void:
	if not menu_scene:
		push_warning("ContextMenuHandler: menu_scene is not assigned.")
		return
		
	hide_context_menu()
	context_menu_data = data
	
	context_menu = menu_scene.instantiate() as Control
	var root = get_tree().root
	root.add_child(context_menu)
	context_menu.global_position = pos
	
	if context_menu.has_method("setup_options"):
		context_menu.setup_options(data)
	
	if context_menu.has_signal("delete_pressed"):
		context_menu.delete_pressed.connect(_on_action.bind("delete"))
	if context_menu.has_signal("duplicate_pressed"):
		context_menu.duplicate_pressed.connect(_on_action.bind("duplicate"))
	if context_menu.has_signal("show_in_file_system_pressed"):
		context_menu.show_in_file_system_pressed.connect(_on_action.bind("show_in_file_system"))
	if context_menu.has_signal("rename_pressed"):
		context_menu.rename_pressed.connect(_on_action.bind("rename"))
	if context_menu.has_signal("new_folder_pressed"):
		context_menu.new_folder_pressed.connect(_on_action.bind("new_folder"))
		
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func hide_context_menu() -> void:
	if context_menu:
		if get_viewport().gui_focus_changed.is_connected(_on_focus_changed):
			get_viewport().gui_focus_changed.disconnect(_on_focus_changed)
		context_menu.queue_free()
		context_menu = null
		context_menu_data = null

func _on_focus_changed(node: Control) -> void:
	if context_menu and not context_menu.is_ancestor_of(node) and node != context_menu:
		print("[DEBUG ContextMenu] Hiding menu via _on_focus_changed! Focus went to: ", str(node.name) if node else "null")
		hide_context_menu()

func _input(event: InputEvent) -> void:
	if context_menu and event is InputEventMouseButton and event.pressed:
		var rect = Rect2(context_menu.global_position, context_menu.size)
		if not rect.has_point(event.global_position):
			print("[DEBUG ContextMenu] Hiding menu via _input! Mouse: ", event.global_position, " MenuRect: ", rect)
			hide_context_menu()
		else:
			print("[DEBUG ContextMenu] Mouse is INSIDE menu rect (", event.global_position, "). Click allowed.")

func _on_action(action: String) -> void:
	print("[DEBUG ContextMenu] Action button pressed: ", action)
	action_requested.emit(action, context_menu_data)
	hide_context_menu()
