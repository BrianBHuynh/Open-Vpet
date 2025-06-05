extends RichTextLabel


func _physics_process(_delta: float) -> void:
	text = "Food: " + str(int(Status.get_stat("food"))) + "\nHappiness: " + str(int(Status.get_stat("happiness"))) + "\nStrength: " + str(int(Status.get_stat("strength"))) + "\nWins: " + str(int(Saves.get_or_return("stats", "wins", 0))) + "\nEnergy: " + str(int(Status.get_stat("energy")))
