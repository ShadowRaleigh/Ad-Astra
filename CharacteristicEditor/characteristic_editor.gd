extends Control

@export var tag_editor: TagEditorController
@export var rule_editor: RuleEditorController
@export var file_browser: FileBrowserController
@export var context_menu_handler: ContextMenuHandler
@export var characteristic_action_executor: CharacteristicActionExecutor

@onready var name_input: LineEdit = %NameInput
@onready var material_cost_input: LineEdit = %MaterialCostInput
@onready var description_input: TextEdit = %DescriptionInput
@onready var type_option: OptionButton = %TypeOption
@onready var min_tier_input: SpinBox = %MinTierInput
@onready var max_tier_input: SpinBox = %MaxTierInput
@onready var cost_factor_input: SpinBox = %CostFactorInput
@onready var save_button: Button = %SaveButton

var current_data: CharacteristicData = null
var current_file_id: String = ""

## Inicializa a interface e conecta os sinais dos componentes de editor.
func _ready() -> void:
	save_button.pressed.connect(_on_save)
	
	if not tag_editor or not rule_editor or not file_browser:
		push_error("CharacteristicEditor: Faltam as referências dos componentes novos (TagEditor, RuleEditor, FileBrowser)!")
		return
		
	# Conexões do FileBrowser
	file_browser.file_selected.connect(func(loaded_data, file_id): 
		current_data = loaded_data
		current_file_id = file_id
		_populate_ui(current_data)
	)
	file_browser.new_characteristic_requested.connect(_new_characteristic)
	file_browser.file_deleted.connect(func(deleted_id):
		if current_file_id == deleted_id or current_file_id.begins_with(deleted_id + "/"):
			_new_characteristic()
	)
	
	# Quando as tags ou as regras mudam nos subcomponentes, a resource version não muda no ato porque eles
	# apenas alteram memory-state. Quando o usuário clica me "Salvar Característica", nós persistimos tudo.
	
	_new_characteristic()

## Limpa o formulário preparando o editor para criar uma nova característica do zero.
func _new_characteristic() -> void:
	current_data = CharacteristicData.new()
	current_file_id = ""
	current_data.characteristic_id = ""
	_populate_ui(current_data)
	if is_instance_valid(file_browser):
		file_browser.deselect_all()

## Preenche os campos visuais da interface com os dados da característica enviada.
func _populate_ui(data: CharacteristicData) -> void:
	name_input.text = data.characteristic_name
	description_input.text = data.description
	type_option.clear()
	for type_name in Enums.CharacteristicType.keys():
		type_option.add_item(type_name)
	type_option.select(data.type)
	min_tier_input.value = data.min_tier
	max_tier_input.value = data.max_tier
	material_cost_input.text = data.material_cost
	cost_factor_input.value = data.cost_factor
	
	# Delega o preenchimento aos subsistemas
	if is_instance_valid(tag_editor):
		tag_editor.load_tags(data)
	
	if is_instance_valid(rule_editor):
		rule_editor.load_rules(data)

## Salva a característica atual no disco criando ou renomeando seu arquivo conforme necessário.
func _on_save() -> void:
	if not current_data:
		current_data = CharacteristicData.new()
		
	var base_name = name_input.text
	if base_name == "":
		base_name = "Nova Caracteristica"
		
	var expected_safe_base = DataManager.get_safe_filename(base_name)
	var new_file_id = current_file_id
	
	var target_folder := ""
	if current_file_id != "":
		target_folder = current_file_id.get_base_dir()
	elif is_instance_valid(file_browser):
		var selected = file_browser.file_list.get_selected()
		if selected:
			var meta = selected.get_metadata(0)
			if meta is Dictionary:
				if meta.get("type") == "dir": target_folder = meta.get("path")
				elif meta.get("type") == "file": target_folder = (meta.get("id") as String).get_base_dir()
	
	# Gera ID se for novo ou tiver nome principal modificado
	if current_file_id == "" or current_file_id.get_file() != expected_safe_base:
		new_file_id = DataManager.generate_unique_filename_in_folder("characteristics", target_folder, base_name)
		
		# Se renomeamos o arquivo para valer, deleta a versão antiga
		if current_file_id != "" and current_file_id != new_file_id:
			DataManager.delete_resource("characteristics", current_file_id)
			
	current_file_id = new_file_id
	current_data.characteristic_id = current_file_id
		
	current_data.characteristic_name = name_input.text
	current_data.description = description_input.text
	current_data.type = type_option.selected as Enums.CharacteristicType
	current_data.min_tier = int(min_tier_input.value)
	current_data.max_tier = int(max_tier_input.value)
	current_data.material_cost = material_cost_input.text
	current_data.cost_factor = cost_factor_input.value
	
	# Rules e Tags já editam o 'current_data' internamente in-place, logo não precisam ser lidas de volta da tela
	
	current_data.resource_version += 1
	DataManager.save_resource(current_data, "characteristics", current_file_id)
	
	if is_instance_valid(file_browser):
		file_browser.refresh_file_list()
