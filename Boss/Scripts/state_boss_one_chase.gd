# state_chase.gd

extends State

class_name BossOneChaseState


func _ready():
	animation_player.play("chase")
	persistent_state.detection.connect("body_exited", self, "no_chase")


func no_chase(_param):
	persistent_state.player_detected = false

	
func _physics_process(_delta):
	moveHandler()

func moveHandler():
	#if persistent_state.player_detected:
	var look = persistent_state.get_node("RayCast2D")
	look.cast_to = (persistent_state.target.position - persistent_state.position)
	look.force_raycast_update()
	
	if !look.is_colliding():
		persistent_state.dir = look.cast_to.normalized()
	else:
		for scent in persistent_state.target.scent_trail:
			look.cast_to = scent.position - persistent_state.position
			look.force_raycast_update()
			
			if !look.is_colliding():
				persistent_state.dir = look.cast_to.normalized()
				break
	#else:
		#persistent_state.change_state("idle")
