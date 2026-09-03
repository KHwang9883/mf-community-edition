extends Command

static func register() -> Command:
	return new() \
		.set_name("toast") \
		.add_param("text", TYPE_STRING) \
		.set_description("Shows an achievement toast with the given text") \
		.set_not_cheat()

func execute(args: Array) -> Command.ExecuteResult:
	var text: String = " ".join(args)
	SecretsManager.queue_achievement(text, "tasty toast appears!")
	return Command.ExecuteResult.new("Queued achievement toast")
