extends Node
class_name RuleEditorController

@export var restrictions_list: ItemList
@export var add_restriction_button: Button
@export var remove_restriction_button: Button

@export var modifiers_list: ItemList
@export var add_modifier_button: Button
@export var remove_modifier_button: Button

signal rules_changed

var current_data: CharacteristicData
var rule_picker: Window
var _current_editing_rule_type: String = ""

func _ready() -> void:
	if not restrictions_list or not add_restriction_button or not modifiers_list or not add_modifier_button:
		push_warning("RuleEditorController: Faltam referências de UI!")
		return
		
	add_restriction_button.pressed.connect(_on_add_restriction)
	remove_restriction_button.pressed.connect(_on_remove_restriction)
	add_modifier_button.pressed.connect(_on_add_modifier)
	remove_modifier_button.pressed.connect(_on_remove_modifier)
	
	var picker_scene = preload("res://CharacteristicEditor/RuleEditor/rule_picker_popup.tscn")
	rule_picker = picker_scene.instantiate()
	add_child(rule_picker)
	rule_picker.rule_selected.connect(_on_rule_selected)

func load_rules(data: CharacteristicData) -> void:
	current_data = data
	if not is_instance_valid(restrictions_list) or not is_instance_valid(modifiers_list): return
	
	restrictions_list.clear()
	modifiers_list.clear()
	
	if not current_data: return
	
	for rest in current_data.restrictions: 
		restrictions_list.add_item(rest.rule_name if rest.rule_name != "" else "Restrição sem nome")
		
	for mod in current_data.modifiers: 
		modifiers_list.add_item(mod.rule_name if mod.rule_name != "" else "Modificador sem nome")

func _on_add_restriction() -> void:
	_current_editing_rule_type = "restriction"
	rule_picker.open("Restrictions")

func _on_add_modifier() -> void:
	_current_editing_rule_type = "modifier"
	rule_picker.open("Modifiers")

func _on_rule_selected(rule: CharacteristicRule) -> void:
	if not current_data: return
	
	if _current_editing_rule_type == "restriction" and rule is CharacteristicRestriction:
		for existing in current_data.restrictions:
			if existing.get_script() == rule.get_script():
				push_warning("Característica já possui esta restrição!")
				return
		current_data.restrictions.append(rule)
		load_rules(current_data)
		rules_changed.emit()
		
	elif _current_editing_rule_type == "modifier" and rule is CharacteristicModifier:
		for existing in current_data.modifiers:
			if existing.get_script() == rule.get_script():
				push_warning("Característica já possui este modificador!")
				return
		current_data.modifiers.append(rule)
		load_rules(current_data)
		rules_changed.emit()

func _on_remove_restriction() -> void:
	if not current_data: return
	
	var selected = restrictions_list.get_selected_items()
	if selected.size() > 0:
		current_data.restrictions.remove_at(selected[0])
		load_rules(current_data)
		rules_changed.emit()

func _on_remove_modifier() -> void:
	if not current_data: return
	
	var selected = modifiers_list.get_selected_items()
	if selected.size() > 0:
		current_data.modifiers.remove_at(selected[0])
		load_rules(current_data)
		rules_changed.emit()
