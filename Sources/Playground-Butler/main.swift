import Core

VersionCommand.version = "0.0.3"

var registry = CommandRegistry(usage: "<command> <options>", overview: "Playground Butler makes playgrounds creation fast and not boring.")
registry.register(command: CopyTemplateCommand.self)
registry.register(command: SelectTemplateCommand.self)
registry.register(command: EditConfigurationCommand.self)
registry.register(command: LastOpenedCommand.self)
registry.register(command: ViewConfigurationCommand.self)
registry.register(command: VersionCommand.self)
registry.run()



