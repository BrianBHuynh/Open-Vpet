extends Node


func _ready() -> void:
	initialize()
	SignalBus.load_finished.connect(initialize)


func initialize() -> void:
	Status.init_stat("food", 100.0, -0.0011574074, 100.0, 0.0)
	Status.init_stat("happiness", 100.0, -0.05, 100.0, 0.0)
	Status.init_stat("strength", 100.0, -0.005, 100.0, 0.0)
	Status.init_stat("energy", 100.0, -0.0011574074, 100.0, 0.0)


func feed(satiety: float) -> void:
	Status.change_stat("food", satiety)
