# state_factory.gd

class_name BossOneStateFactory

var states

func _init():
	states = {
		"idle": BossOneIdleState,
		"chase": BossOneChaseState,
		"attack": BossOneAttackState,
}


func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")