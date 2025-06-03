extends Node


var tasks_queue: Array = []


func _ready() -> void:
	SignalBus.clear_tasks.connect(clear_tasks)


func add_task(task: Callable) -> void:
	tasks_queue.append(WorkerThreadPool.add_task(auto_clear.bind(task)))


func auto_clear(task: Callable) -> void:
	task.call()
	SignalBus.clear_tasks.emit.call_deferred()


func clear_tasks() -> void:
	for task: int in tasks_queue:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			tasks_queue.erase(task)
