extends Node

enum GAME_STATE {PREGAME, INPROGRESS, PAUSED, GAMEOVER}
enum DELIVERY_STATUS {STARTED, RETRIEVED, DELIVERED, FAILED = -1}
enum DELIVERY_TYPE {OXYGEN, C02, OTHER = -1}

var _current_room: RoomBounds = null
var _current_delivery: Delivery = null
var _completed_deliveries := 0

var game_state = GAME_STATE.PREGAME
var main_scene: Main = null
var gui: Gui = null
var player: BoatCharacter = null
var paths: Array[BloodRiver] = []
var rooms: Array[RoomBounds] = []
var room_name_to_resource: Dictionary = {}
var room_to_bounds: Dictionary = {}
var map_graph: Dictionary = {}
var shortest_path_arr: Array = []
var enemies_node: Node3D = null
var pickups_node: Node3D = null
var spawn_manager: SpawnManager = null
var for_shaders: Node3D = null
var first_delivery := true

# vars to not be reset on replay
var delivery_list: DeliveryList = preload("res://core/delivery/resources/delivery_list.tres")
var new_delivery_list := {}
var virus_scene = preload("res://prefabs/cells/virus.tscn")
var spawn_manager_class = preload("res://core/spawn_manager.tscn")
var mouse_sensitivity := 1.0
var volume_modifier := 1.0
var default_volume: float
var organ_list: Array[Room] = []
var left_lung = null
var right_lung = null
var other_organs := []

func _ready() -> void:
	initialize_game()
	default_volume = AudioServer.get_bus_volume_linear(0)

func initialize_game() -> bool:
	main_scene = get_tree().current_scene
	if not main_scene:
		return false
	gui = main_scene.find_child("Gui")
	player = main_scene.find_child("BoatCharacter")
	enemies_node = main_scene.find_child("Enemies")
	pickups_node = main_scene.find_child("Pickups")
	for_shaders = main_scene.find_child("ForShaders")

	spawn_manager = spawn_manager_class.instantiate()
	main_scene.add_child(spawn_manager)

	# construct graph for paths between rooms
	for child in main_scene.find_children("*"):
		# print(child, is_instance_of(child, BloodRiver))
		if is_instance_of(child, BloodRiver):
			var river: BloodRiver = child
			paths.append(child)
			var source := str(river.source_room)
			var destination := str(river.destination_room)
			var edge_weight = river.curve.get_baked_length()
			if map_graph.get(source):
				map_graph.get(source)[destination] = edge_weight
			else:
				map_graph[source] = {destination: edge_weight}
		if is_instance_of(child, RoomBounds):
			var bounds: RoomBounds = child
			rooms.append(child)
			room_to_bounds[bounds.room_resource] = bounds

			# set lungs
			if str(bounds).contains("Left Lung"):
				left_lung = bounds.room_resource
			elif str(bounds).contains("Right Lung"):
				right_lung = bounds.room_resource

			if not str(child).contains("Junction"):
				other_organs.append(bounds.room_resource)
				

			if not room_name_to_resource.get(str(bounds)):
				room_name_to_resource[str(bounds)] = bounds.room_resource

	for organ in other_organs:
		if new_delivery_list.get(organ):
			new_delivery_list[organ].append()
		else:
			new_delivery_list[organ] = [left_lung, right_lung]
	
	new_delivery_list[left_lung] = other_organs
	new_delivery_list[right_lung] = other_organs

	print("Map Graph: ", map_graph)
	# print(dijkstra(map_graph, "Heart Left Atrium 2", "Heart Left Atrium 1"))
	actor_setup.call_deferred()
	GameManager.update_game_state(GameManager.GAME_STATE.INPROGRESS)
	return true

func initialize_deferred():
	await get_tree().physics_frame
	if not initialize_game():
		initialize_deferred.call_deferred()
		return
	get_tree().paused = false

func replay():
	# reset necessary variables
	_current_room = null
	_current_delivery = null
	_completed_deliveries = 0

	game_state = GAME_STATE.PREGAME
	main_scene = null
	gui = null
	player = null
	paths= []
	rooms = []
	room_name_to_resource = {}
	room_to_bounds = {}
	map_graph = {}
	shortest_path_arr = []
	enemies_node = null
	pickups_node = null
	spawn_manager = null
	for_shaders = null
	first_delivery = true

	get_tree().change_scene_to_file("res://levels/mainlevel.tscn")
	# get_tree().change_scene_to_packed(
	initialize_deferred.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	if main_scene and main_scene.navigation_region:
		spawn_manager.initialize(main_scene.navigation_region)

	await get_tree().create_timer(1.0).timeout
	for child in for_shaders.get_children():
		child.queue_free()
	gui.loading_screen.visible = false
	# spawn_manager.spawn_enemies()
	# spawn_manager.spawn_pickups()
	# spawn 1 virus per room
	# for room in rooms:
	# 	var new_virus: Virus = virus_scene.instantiate()
	# 	enemies_node.add_child(new_virus)
	# 	new_virus.global_position = room.global_position

	if gui:
		gui.set_fading_message("You are a Red Blood Cell!\nDeliver oxygen to organs and defeat viruses with white blood cells!", 5.0)

func pause():
	update_game_state(GAME_STATE.PAUSED)
	gui.pause_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func resume():
	update_game_state(GAME_STATE.INPROGRESS)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	get_tree().paused = false

func set_volume(volume: float):
	volume_modifier = volume
	AudioServer.set_bus_volume_linear(0, default_volume * volume_modifier)

func get_timer() -> float:
	return player.time_alive

func _process(_delta: float) -> void:
	if game_state == GAME_STATE.GAMEOVER:
		get_tree().paused = true
		gui.game_over()
		return

	if not game_state == GAME_STATE.INPROGRESS:
		return

	if not player:
		return
	
	gui.health_bar.value = player.health
	gui.gas_bar.value = player.gas
	gui.set_timer(player.time_alive)
	if _current_delivery == null:
		set_current_delivery(get_next_delivery())
	else:
		gui.delivery_status.text = DELIVERY_STATUS.keys()[_current_delivery.delivery_status]

func update_game_state(new_state: GAME_STATE):
	print("new game state %s" % [GAME_STATE.keys()[new_state]])
	game_state = new_state

func get_next_delivery() -> Delivery:
	var delivery_list_arr := delivery_list.delivery_list
	var base_delivery: Delivery = delivery_list_arr.pick_random().duplicate(true)
	if first_delivery:
		first_delivery = false
		var choice_lung = left_lung if randi_range(0, 1) == 0 else right_lung
		base_delivery.source = choice_lung
		base_delivery.destination = new_delivery_list.get(choice_lung).pick_random()
		print('assigned first delivery')
	elif _current_room != null:
		var possible_next_rooms: Array = new_delivery_list.get(_current_room.room_resource)
		base_delivery.source = _current_room.room_resource
		base_delivery.destination = possible_next_rooms.pick_random()
		print('assigned delivery from current room')
	else:
		base_delivery.source = left_lung
		base_delivery.destination = new_delivery_list.get(left_lung).pick_random()
		print('assigned a lung delivery...')
		
	if str(base_delivery.source).contains("Lung"):
		base_delivery.delivery_type = GameManager.DELIVERY_TYPE.OXYGEN
	else:
		base_delivery.delivery_type = GameManager.DELIVERY_TYPE.C02
	return base_delivery

func update_shortest_path():
	# update shortest path calculation
	if _current_delivery != null:
		if _current_delivery.delivery_status == DELIVERY_STATUS.STARTED:
			shortest_path_arr = dijkstra(map_graph, str(_current_room), str(_current_delivery.source))
		elif _current_delivery.delivery_status == DELIVERY_STATUS.RETRIEVED:
			shortest_path_arr = dijkstra(map_graph, str(_current_room), str(_current_delivery.destination))

func set_current_room(new_room: RoomBounds) -> void:
	if new_room != _current_room:
		print("Room changed to %s" % [str(new_room)])
		_current_room = new_room
		if _current_room != null:
			gui.set_current_room_label(str(_current_room.room_resource))
			update_shortest_path()
			update_delivery_status()

			# temporarily set enemy target location to our room
			# for child in main_scene.find_children("*", "Virus"):
			#     child.set_target(_current_room.global_position)
		else:
			gui.set_current_room_label('Veins')
		
func update_delivery_status():
	if not _current_delivery:
		return

	var past_delivery: Delivery = _current_delivery.duplicate(true)

	if _current_delivery.delivery_status == DELIVERY_STATUS.STARTED:
		if str(_current_room.room_resource) == str(_current_delivery.source):
			# TODO make a fading message that displays on screen here
			_current_delivery.delivery_status = DELIVERY_STATUS.RETRIEVED
			gui.set_next_location_label(str(_current_delivery.destination))
			return
	elif _current_delivery.delivery_status == DELIVERY_STATUS.RETRIEVED:
		if str(_current_room.room_resource) == str(_current_delivery.destination):
			_current_delivery.delivery_status = DELIVERY_STATUS.DELIVERED
			# TODO make a timer here that sets it to null after a few seconds instead of immediately
			_completed_deliveries += 1
			# update gui completed deliveries
			gui.completed_deliveries.text = str(_completed_deliveries)

			# set current delivery to none
			set_current_delivery(null)

	if _current_delivery != null and past_delivery.delivery_status != _current_delivery.delivery_status:
		print("Delivery Status updated to %s" % [str(DELIVERY_STATUS.keys()[_current_delivery.delivery_status])])

func set_current_delivery(new_delivery) -> void:
	if new_delivery != _current_delivery:
		print("Delivery changed to %s" % [str(new_delivery)])
		_current_delivery = new_delivery

		# TODO make a signal for delivery update or something? 
		# where should i update deliveries?
		if _current_delivery != null:
			gui.set_next_location_label(str(_current_delivery.source))
			gui.set_current_mission_label(str(_current_delivery))
			update_shortest_path()
		else:
			gui.set_next_location_label("None")
			gui.set_current_mission_label("Wait for next assignment")

# asked a certain chat website for assistance in writing this
static func dijkstra(graph: Dictionary, start: String, goal: String) -> Array:
	var unvisited = graph.keys()
	var distances = {}
	var previous = {}

	for node in unvisited:
		distances[node] = INF
		previous[node] = null
	distances[start] = 0
	
	while unvisited.size() > 0:
		# Find unvisited node with smallest distance
		unvisited.sort_custom(func(a, b): return distances[a] < distances[b])
		var current = unvisited[0]
		unvisited.remove_at(0)

		if current == goal:
			break
		
		for neighbor in graph[current]:
			var cost = graph[current][neighbor]
			var alt = distances[current] + cost
			if alt < distances[neighbor]:
				distances[neighbor] = alt
				previous[neighbor] = current

	# Reconstruct path
	var path = []
	var node = goal
	while node:
		path.insert(0, node)
		node = previous[node]
	
	return path
	
