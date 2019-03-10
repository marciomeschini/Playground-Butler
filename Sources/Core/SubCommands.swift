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
  
  public func run(with arguments: ArgumentParser.Result, configuration: Configuration) throws {
    guard let source = arguments.get(source) else { return }
    copyAndOpen(CopyTemplate(source), configuration: configuration)
  }
}

// MARK: -

public struct SelectTemplateCommand: Command {
  public let command = "select"
  public let overview = "Select from template list."
  
  public init(parser: ArgumentParser) {
    parser.add(subparser: command, overview: overview)
  }
  
  public func run(with arguments: ArgumentParser.Result, configuration: Configuration) throws {
    let pathExtension = configuration.pathExtension
    let all = Template.contentsOfDirectory(configuration.templates, ofType: pathExtension)
    let menuItems: [String] = all.enumerated()
      .map { "[\($0)]: \($1.prettyDescription)" }
    print(menuItems.joined(separator: "\n"))

    var selected: Int? = nil
    while selected == nil {
      print("Please select the template:")
      let inputString = getInput()
      if let value = Int(inputString), all.indices.contains(value) {
        selected = value
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
