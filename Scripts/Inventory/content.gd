extends GridContainer

@export var item_card_scene: PackedScene
#@export var datas: Array[ItemData] = []


signal item_selected(material)

func _ready() -> void:
	if not FirebaseManager.on_data_loaded.is_connected(_populate):
		FirebaseManager.on_data_loaded.connect(_populate)
	if not PlayerData.has_loaded_data:
		PlayerData.load_local()
	refresh_from_local()
	#load_data()
	
#func load_data():
	#for child in get_children():
		#child.queue_free()
	#
	#for data in datas:
		#if item_scene and data:
			#var instance = item_scene.instantiate()
			#add_child(instance)
			#instance.setup(data)
			#instance.item_clicked.connect(_on_item_clicked)

func _on_item_clicked(material):
	#print("bag material from signal is ", material)
	item_selected.emit(material)

func refresh_from_local() -> void:
	PlayerData.load_local()
	if CatalogManager.is_loaded():
		_populate()
	else:
		if not CatalogManager.catalog_loaded.is_connected(_populate):
			CatalogManager.catalog_loaded.connect(_populate, CONNECT_ONE_SHOT)
		CatalogManager.load_catalog()

func _populate() -> void:
	for c in get_children():
		c.queue_free()

	var seen = []

	for item_id in PlayerData.bags_owned:
		if item_id == "":
			continue
		if item_id in seen:
			continue
		if not CatalogManager.has_item(item_id):
			continue
		seen.append(item_id)
		var card = item_card_scene.instantiate()
		card.item_clicked.connect(_on_item_clicked)
		add_child(card)
		card.setup(item_id, "Cornbags")

	for item_id in PlayerData.boards_owned:
		if item_id in seen:
			continue
		if not CatalogManager.has_item(item_id):
			continue
		seen.append(item_id)
		var card = item_card_scene.instantiate()
		add_child(card)
		card.setup(item_id, "Boards")
