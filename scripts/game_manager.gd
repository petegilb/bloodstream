extends Node3D

var _current_room: RoomBounds = null
var _current_delivery: Delivery = null

var main_scene: Node3D = null
var gui: Gui = null
var paths: Array[BloodRiver] = []
var rooms: Array[RoomBounds] = []
var map_graph: Dictionary = {}

func _ready() -> void:
    main_scene = get_tree().current_scene
    gui = main_scene.find_child("Gui")

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
            rooms.append(child)
    
    print("Map Graph: ", map_graph)
    # print(dijkstra(map_graph, str(rooms[0]), str(rooms[0])))

func set_current_room(new_room) -> void:
    if new_room != _current_room:
        print("Room changed to %s" % [str(new_room)])
        _current_room = new_room
        if _current_room != null:
            gui.set_current_room_label(str(_current_room.room_resource))
        else:
            gui.set_current_room_label('Unknown')

func set_current_delivery(new_delivery) -> void:
    if new_delivery != _current_delivery:
        print("Delivery changed to %s" % [str(new_delivery)])
        _current_delivery = new_delivery

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
