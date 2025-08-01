extends Node3D

enum DELIVERY_STATUS {STARTED, RETRIEVED, DELIVERED, FAILED = -1}
enum DELIVERY_TYPE {OXYGEN, C02, OTHER = -1}

var _current_room: RoomBounds = null
var _current_delivery: Delivery = null

var main_scene: Node3D = null
var gui: Gui = null
var player: BoatCharacter = null
var paths: Array[BloodRiver] = []
var rooms: Array[RoomBounds] = []
var room_name_to_resource: Dictionary = {}
var room_to_bounds: Dictionary = {}
var map_graph: Dictionary = {}
var shortest_path_arr: Array = []

var delivery_list: DeliveryList = preload("res://core/delivery/resources/delivery_list.tres")

func _ready() -> void:
    main_scene = get_tree().current_scene
    gui = main_scene.find_child("Gui")
    player = main_scene.find_child("BoatCharacter")

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

            if not room_name_to_resource.get(str(bounds)):
                room_name_to_resource[str(bounds)] = bounds.room_resource
    
    print("Map Graph: ", map_graph)
    # print(dijkstra(map_graph, "Heart Left Atrium 2", "Heart Left Atrium 1"))

func _process(_delta: float) -> void:
    if not player:
        return
    
    if _current_delivery == null:
        set_current_delivery(get_next_delivery())

func get_next_delivery() -> Delivery:
    var delivery_list_arr := delivery_list.delivery_list
    return delivery_list_arr.pick_random().duplicate(true)

func update_shortest_path():
    # update shortest path calculation
    if _current_delivery != null:
        if _current_delivery.delivery_status == DELIVERY_STATUS.STARTED:
            shortest_path_arr = dijkstra(map_graph, str(_current_room), str(_current_delivery.source))
        elif _current_delivery.delivery_status == DELIVERY_STATUS.RETRIEVED:
            shortest_path_arr = dijkstra(map_graph, str(_current_room), str(_current_delivery.destination))

func set_current_room(new_room) -> void:
    if new_room != _current_room:
        print("Room changed to %s" % [str(new_room)])
        _current_room = new_room
        if _current_room != null:
            gui.set_current_room_label(str(_current_room.room_resource))
            update_shortest_path()
        else:
            gui.set_current_room_label('Veins')
        
        # TODO temporarily update delivery here until we have a better way

func set_current_delivery(new_delivery) -> void:
    if new_delivery != _current_delivery:
        print("Delivery changed to %s" % [str(new_delivery)])
        _current_delivery = new_delivery

        # TODO make a signal for delivery update or something? 
        # where should i update deliveries?
        gui.set_next_location_label(str(_current_delivery.source))
        gui.set_current_mission_label(str(_current_delivery))
        update_shortest_path()

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
