class_name TutorialStage
extends Stage

@export var tutorial_steps : Array[String] = [
	"move",
	"jump",
	"attack", 
	"jumpkick",
	"swap",
	"attack",
]



var step_index := 0

func _init() -> void:
	#super._init()
	start_step()

func start_step() -> void:
	var step := tutorial_steps[step_index]
	StageManager.show_tutorial_prompt.emit(step_index)


	match step:
		"move":
			wait_for_action(Player.State.WALK)
		"jump":
			wait_for_action(Player.State.TAKEOFF)
		"attack":
			wait_for_action(Player.State.ATTACK)
		"jumpkick":
			wait_for_action(Player.State.JUMPKICK)
		"swap":
			wait_for_action(Player.State.SWAP)
		"attack":
			wait_for_action(Player.State.ATTACK)
	

func complete_step() -> void:
	step_index += 1
	if step_index >= tutorial_steps.size():
		StageManager.show_tutorial_prompt.emit(8)
		StageManager.stage_complete.emit()
		return

	start_step()


func wait_for_action(State : Player.State):
	while true:
		var state = await EntityManager.Player_Acted
		if state == State:
			print(tutorial_steps[step_index])
			break 
	complete_step()
