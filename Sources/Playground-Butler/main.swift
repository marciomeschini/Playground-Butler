import Core

var registry = CommandRegistry(usage: "<command> <options>", overview: "Playground Butler makes playground creation fast and not boring.")
registry.register(command: CopyTemplateCommand.self)
registry.register(command: SelectTemplateCommand.self)
registry.run()



