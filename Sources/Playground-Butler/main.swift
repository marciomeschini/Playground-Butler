import Core

var registry = CommandRegistry(usage: "<command> <options>", overview: "Playground-Butler")
registry.register(command: CopyTemplate.self)
registry.register(command: SelectTemplate.self)
registry.run()



