import Foundation
import Utility
import Cocoa

func copy(_ template: Foundation.URL, to folder: Foundation.URL) -> Foundation.URL {
  // input
  print("Template: \(template.lastPathComponent)")
  let fileManager = FileManager.default
  
  // output
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyyMMdd"
  let formattedDate = formatter.string(from: Date())
  let todayFolder = folder.appendingPathComponent(formattedDate)
  if !fileManager.fileExists(atPath: todayFolder.path) {
    try! fileManager.createDirectory(atPath: todayFolder.path, withIntermediateDirectories: true, attributes: nil)
  }
  let lastPath = template.lastPathComponent
  let destination = todayFolder.appendingPathComponent(lastPath)
  print("Destination: \(destination)")
  
  // check if exists
  let fileExists = fileManager.fileExists(atPath: destination.path)
  if !fileExists {
    print("File not found: create a new one")
    try! fileManager.copyItem(at: template, to: destination)
  } else {
    print("Found file.")
  }
  return destination
}

@discardableResult
func openFile(_ url: Foundation.URL) -> Bool {
  print("Opening...")
  return NSWorkspace.shared.openFile(url.path)
}

/*
  INPUT
  - target folder
  - template
 */

public struct CopyTemplate: Command {
  public let command = "copy"
  public let overview = "Copy <input> template to today folder."
  let template: PositionalArgument<String>
  let folder = URL(fileURLWithPath: "/Users/marcomeschini/Development/Playground")
  
  public init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    template = subparser.add(
      positional: "input",
      kind: String.self,
      optional: false,
      usage: "The template to be used."
    )
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    guard let selected = arguments.get(template) else { return }
    
    // input
    let selectedTemplate = URL(fileURLWithPath: selected)
    let destination = copy(selectedTemplate, to: folder)
    
    // open
    openFile(destination)
  }
}

/*
  INPUT
  - target folder
  - template folder
 */

public struct SelectTemplate: Command {
  public let command = "select"
  public let overview = "Select template from default folder."
  let folder = URL(fileURLWithPath: "/Users/marcomeschini/Development/Playground")
  let templatesFolder = URL(fileURLWithPath: "/Users/marcomeschini/Development/Playground/.templates")
  
  public init(parser: ArgumentParser) {
    parser.add(subparser: command, overview: overview)
  }
  
  public func run(with arguments: ArgumentParser.Result) throws {
    let playgroundExtension = "playground"
    let fileManager = FileManager.default
    let contents = try! fileManager.contentsOfDirectory(atPath: templatesFolder.path)
      .filter { $0.hasSuffix(playgroundExtension) }
      .sorted(by: { (lhs, rhs) -> Bool in
        let lhsURL = URL(fileURLWithPath: lhs)
        let rhsURL = URL(fileURLWithPath: rhs)
        return lhsURL.lastPathComponent > rhsURL.lastPathComponent
      })
    for (index, element) in contents.enumerated() {
      let prettyName = element.replacingOccurrences(of: ".\(playgroundExtension)", with: "")
      print("[\(index)]: \(prettyName)")
    }
    var userSelection: Int? = nil
    while userSelection == nil {
      print("Please select the template:")
      let inputString = getInput()
      if let value = Int(inputString), contents.indices.contains(value) {
        userSelection = value
      } else {
        print("Selection not valid! Choose number between: 0 and \(contents.count).")
      }
    }
    let element = contents[userSelection!]
    let selectedTemplate = templatesFolder.appendingPathComponent(element)
    let destination = copy(selectedTemplate, to: folder)
    
    openFile(destination)
  }
  
  func getInput() -> String {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    let inputString = String(bytes: inputData, encoding: .utf8)!
    return inputString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }
}
