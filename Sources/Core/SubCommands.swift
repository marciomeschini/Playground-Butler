import Foundation
import Utility
import Cocoa

// MARK: -

extension Command {
  @discardableResult
  func openFile(_ url: Foundation.URL) -> Bool {
    print("Opening...")
    return NSWorkspace.shared.openFile(url.path)
  }
  
  func copyAndOpen(_ template: CopyTemplate, configuration: Configuration) {
    let destination = template.copyIfNeeded(to: configuration.target)
    openFile(destination)
  }
}

// MARK: -

enum CommandError: Error {
  case templatesNotFound(Foundation.URL)
}

extension CommandError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .templatesNotFound(url):
      return NSLocalizedString("Templates not found. Please add some templates to \(url)", comment: "")
    }
  }
}

// MARK: -

public struct CopyTemplateCommand: Command {
  public let command = "copy"
  public let overview = "Copy <source_file> to today folder."
  let source: PositionalArgument<String>
  
  public init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    source = subparser.add(
      positional: "source_file",
      kind: String.self,
      optional: false,
      usage: "The source file to copy."
    )
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    guard let source = arguments.get(source) else { return }
    let configuration = try Store.default.configuration()
    copyAndOpen(CopyTemplate(source), configuration: configuration)
  }
}

// MARK: -

public struct SelectTemplateCommand: Command {
  public let command = "select"
  public let overview = "Select from template list or from provided index."
  let index: PositionalArgument<Int>
  
  public init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    index = subparser.add(
      positional: "index",
      kind: Int.self,
      optional: true,
      usage: "The index of the template. [optional]"
    )
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    let configuration = try Store.default.configuration()
    let pathExtension = configuration.pathExtension
    let all = Template.contentsOfDirectory(configuration.templates, ofType: pathExtension)
    guard all.count > 0 else {
      throw CommandError.templatesNotFound(configuration.templates)
    }
    // user provided index
    if let index = arguments.get(index) {
      guard all.indices.contains(index) else {
        print("Index not valid! Choose number between 0 and \(all.count).")
        return
      }
      copyAndOpen(CopyTemplate(template: all[index]), configuration: configuration)
      return
    }
    // interactive
    let menuItems = all.enumerated().map { "[\($0)]: \($1)" }
    print(menuItems.joined(separator: "\n"))
    var selected: Int? = nil
    while selected == nil {
      print("Please select the template:")
      let inputString = getInput()
      if let index = Int(inputString), all.indices.contains(index) {
        selected = index
      } else {
        print("Selection not valid! Choose number between 0 and \(all.count).")
      }
    }
    copyAndOpen(CopyTemplate(template: all[selected!]), configuration: configuration)
  }
  
  func getInput() -> String {
    let inputData = FileHandle.standardInput.availableData
    let inputString = String(bytes: inputData, encoding: .utf8)!
    return inputString.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

// MARK: -

public struct EditConfigurationCommand: Command {
  public let command = "configure"
  public let overview = "Set new configuration."
  let target: PositionalArgument<PathArgument>
  let templates: PositionalArgument<PathArgument>
  
  public init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    target = subparser.add(
      positional: "target",
      kind: PathArgument.self,
      optional: false,
      usage: "The folder to store the playgrounds."
    )
    templates = subparser.add(
      positional: "templates",
      kind: PathArgument.self,
      optional: false,
      usage: "The folder to store the templates."
    )
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    // positional + path types§
    let newTarget = arguments.get(target)?.path.asString ?? ""
    let newTemplates = arguments.get(templates)?.path.asString ?? ""
    let configuration = Configuration(
      target: URL(fileURLWithPath: newTarget),
      templates: URL(fileURLWithPath: newTemplates),
      pathExtension: "playground"
    )
    try Store.default.save(configuration)
  }
}

// MARK: -

public struct ViewConfigurationCommand: Command {
  public let command = "view"
  public let overview = "Show current configuration."
  
  public init(parser: ArgumentParser) {
    parser.add(subparser: command, overview: overview)
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    print(try Store.default.configuration())
  }
}

// MARK: -

public struct VersionCommand: Command {
  public let command = "version"
  public let overview = "Show current version."
  public static var version: String = ""
  
  public init(parser: ArgumentParser) {
    parser.add(subparser: command, overview: overview)
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    print(VersionCommand.version)
  }
}
