extends Window

signal rule_selected(rule: CharacteristicRule)

@onready var rules_list: ItemList = %RulesList
@onready var description_label: Label = %DescriptionLabel
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

var _available_rules: Array[Resource] = []

func _ready() -> void:
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
	confirm_button.pressed.connect(_on_confirm)
	rules_list.item_selected.connect(_on_item_selected)
	rules_list.item_activated.connect(_on_item_activated)

func open(folder_path: String) -> void:
	_available_rules = RuleScanner.scan_folder("res://CharacteristicEditor/Rules/" + folder_path)
	rules_list.clear()
	description_label.text = ""
	
	for i in range(_available_rules.size()):
		var rule = _available_rules[i] as CharacteristicRule
		if rule:
			rules_list.add_item(rule.rule_name if rule.rule_name != "" else rule.resource_path.get_file())
			rules_list.set_item_metadata(i, i)
			
	confirm_button.disabled = true
	popup_centered()

func _on_item_selected(index: int) -> void:
	var rule = _available_rules[index] as CharacteristicRule
	if rule:
		description_label.text = rule.description
		confirm_button.disabled = false

func _on_item_activated(index: int) -> void:
	_on_item_selected(index)
	_on_confirm()

func _on_confirm() -> void:
	var selected = rules_list.get_selected_items()
	if selected.size() > 0:
		var index = selected[0]
		var rule = _available_rules[index] as CharacteristicRule
		
		if rule:
			# Pass a duplicate so each characteristic gets its own independent copy of the rule
			rule_selected.emit(rule.duplicate(true))
			hide()
