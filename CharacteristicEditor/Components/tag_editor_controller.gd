extends Node
class_name TagEditorController

@export var tag_option: OptionButton
@export var add_tag_button: Button
@export var tags_list: ItemList
@export var remove_tag_button: Button

signal tags_changed

var current_data: CharacteristicData

func _ready() -> void:
	if not tag_option or not add_tag_button or not tags_list or not remove_tag_button:
		push_warning("TagEditorController: Faltam referências de UI!")
		return
		
	add_tag_button.pressed.connect(_on_add_tag)
	remove_tag_button.pressed.connect(_on_remove_tag)
	
	tag_option.clear()
	for tag_name in Enums.CharacteristicTag.keys():
		tag_option.add_item(tag_name)

## Preenche a UI visual com as tags dos dados fornecidos
func load_tags(data: CharacteristicData) -> void:
	current_data = data
	if not is_instance_valid(tags_list): return
	
	tags_list.clear()
	if not current_data: return
	
	for tag in current_data.tags:
		if tag < Enums.CharacteristicTag.keys().size():
			var tag_name = Enums.CharacteristicTag.keys()[tag]
			tags_list.add_item(tag_name)
		else:
			tags_list.add_item("Tag Desconhecida (%d)" % tag)

## Adiciona a tag selecionada no OptionButton à lista de tags da característica.
func _on_add_tag() -> void:
	if not current_data: return
	
	var selected_tag = tag_option.selected as Enums.CharacteristicTag
	if not selected_tag in current_data.tags:
		current_data.tags.append(selected_tag)
		load_tags(current_data)
		tags_changed.emit()

## Remove a tag atualmente selecionada na ItemList inferior de tags.
func _on_remove_tag() -> void:
	if not current_data: return
	
	var selected = tags_list.get_selected_items()
	if selected.size() > 0:
		current_data.tags.remove_at(selected[0])
		load_tags(current_data)
		tags_changed.emit()
