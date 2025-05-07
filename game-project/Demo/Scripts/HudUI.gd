extends Control

const HP_PER_NMS = 0.001341022089595

@onready var throttle_bar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/ThrottleProgressBar
@onready var brake_bar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/BrakeProgressBar2
@onready var steering = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/SteeringScroll
@onready var speed = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/SpeedOutput
@onready var gear_label = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/GearLabel
@onready var power_hp = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/PowerHPLabel

func update_stats(stats):
	speed.text = "%05.0f" % stats["forward_speed"]
	power_hp.text = "%05.0f" % abs(stats["power"] * HP_PER_NMS)
	throttle_bar.value = stats["throttle"] * 100
	brake_bar.value = stats["brake"] * 100
	steering.value = stats["steering"]
	gear_label.text = get_gear_value(stats)

func get_gear_value(stats):
	var value = "PARK"
	if stats["gear"] == TestVehicle2D.gears.DRIVE:
		value = "DRIVE"
	if stats["gear"] == TestVehicle2D.gears.NEUTRAL:
		value = "NEUTRAL"
	elif stats["gear"] == TestVehicle2D.gears.REVERSE:
		value = "REVERSE"
	return value
