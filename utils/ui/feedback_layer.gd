class_name FeedbackLayer
extends MessageLayer
## Resolve/fail feedback. Player actions jump the queue; failures wait their turn.


## Replace the current message immediately; queued messages play after it
func show_now(text: String, speaker := "", duration := -1.0, sound := Sound.DEFAULT) -> void:
	_queue.push_front(entry(text, speaker, duration, sound))
	_restart()


## Drop everything and play these entries in order
func play_sequence(messages: Array[Dictionary]) -> void:
	_queue.assign(messages)
	_restart()


func _restart() -> void:
	# Bumping _run_id stops the running loop at its next await.
	_run_id += 1
	_run_queue()
