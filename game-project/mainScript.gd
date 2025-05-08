extends Node2D

@onready var hud_ui = $TestUI/HudUI
@export_node_path("Node2D") var player
@export var camera_scene = preload("res://Demo/Scenes/ChaseCamera.tscn")

func _ready():
	if player:
		player = get_node(player)
		player.add_camera(camera_scene.instantiate())
		player.connect("status_updated", $TestUI.vehicle_updated)
		player.current = true
		player.gear = TestVehicle2D.gears.NEUTRAL
		player.camera.set_process(false)


func _on_sign_punish(n: Variant) -> void:
	player.score(n)

func _on_luksofors_punish(n: Variant) -> void:
	player.score(n)
