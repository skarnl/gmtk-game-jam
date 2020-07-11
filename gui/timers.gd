extends Control

func update_change_time(time_left):
	$update_time.text = str(stepify(time_left, 0.01))
