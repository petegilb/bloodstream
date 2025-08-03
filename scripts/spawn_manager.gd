class_name SpawnManager
extends Node3D

enum DIFFICULTY_STAGES {HEALTHY, SNIFFLES, UNDER_WEATHER, FEVER, VIRAL, HEART}

var virus_scene = preload("res://prefabs/cells/virus.tscn")
var navigation_region: NavigationRegion3D = null
var is_initialized = false

# TODO add high cholesterol or high blood pressure
var difficulty_stages = {
    DIFFICULTY_STAGES.HEALTHY: 'Healthy',
    DIFFICULTY_STAGES.SNIFFLES: 'Case of the Sniffles',
    DIFFICULTY_STAGES.UNDER_WEATHER: 'Under the Weather',
    DIFFICULTY_STAGES.FEVER: 'Fever',
    DIFFICULTY_STAGES.VIRAL: 'Viral Infection',
    DIFFICULTY_STAGES.HEART: 'Heart Attack',
}

var difficulty_modifiers = {
    DIFFICULTY_STAGES.HEALTHY: 1.0,
    DIFFICULTY_STAGES.SNIFFLES: 2.0,
    DIFFICULTY_STAGES.UNDER_WEATHER: 3.0,
    DIFFICULTY_STAGES.FEVER: 4.0,
    DIFFICULTY_STAGES.VIRAL: 5.0,
    DIFFICULTY_STAGES.HEART: 10.0,
}

# when to switch to next difficulty stage (in elapsed minutes)
var difficulty_timing = {
    DIFFICULTY_STAGES.HEALTHY: 0.0,
    DIFFICULTY_STAGES.SNIFFLES: 0.1,
    DIFFICULTY_STAGES.UNDER_WEATHER: .2,
    DIFFICULTY_STAGES.FEVER: 12.0,
    DIFFICULTY_STAGES.VIRAL: 15.0,
    DIFFICULTY_STAGES.HEART: 20.0,
}

var current_difficulty_stage = DIFFICULTY_STAGES.HEALTHY
var next_difficulty_stage = 1

func _ready() -> void:
    update_difficulty_stage_label()

func update_difficulty_stage_label(fading_message:= false):
    if GameManager.gui != null and GameManager.gui.difficulty_stage_label != null:
        GameManager.gui.difficulty_stage_label.text = difficulty_stages.get(current_difficulty_stage)
        if fading_message:
            GameManager.gui.set_fading_message("Difficulty has Increased to %s" % difficulty_stages.get(current_difficulty_stage), 2.0)

func initialize(nav_region: NavigationRegion3D):
    navigation_region = nav_region
    is_initialized = true

func _process(_delta: float) -> void:
    var current_timer = GameManager.get_timer()
    if difficulty_timing.get(next_difficulty_stage)*60 <= current_timer:
        current_difficulty_stage = next_difficulty_stage as DIFFICULTY_STAGES
        next_difficulty_stage += 1
        update_difficulty_stage_label(true)
        print("Difficulty stage updated: %s to %s" % [difficulty_stages.get(current_difficulty_stage-1), difficulty_stages.get(current_difficulty_stage)])
    
func spawn_enemies():
    # NavigationServer3D.map_get_closest_point(()
    pass

func spawn_pickups():
    pass
