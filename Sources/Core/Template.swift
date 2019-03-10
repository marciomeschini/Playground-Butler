import Foundation

// MARK: -

struct Template {
  let url: URL
}

// MARK: -

extension Template {
  init(_ path: String) {
    self.init(url: URL(fileURLWithPath: path))
  }
}

extension Template: CustomStringConvertible {
  var description: String {
    return url.deletingPathExtension().lastPathComponent
  }
}

// MARK: -

extension Template {
  static func contentsOfDirectory(_ url: URL, ofType suffix: String) -> [Template] {
    let fileManager = FileManager.default
    let contents = try? fileManager.contentsOfDirectory(atPath: url.path)
      .filter { $0.hasSuffix(suffix) }
      .sorted(by: { (lhs, rhs) -> Bool in
        let lhsURL = URL(fileURLWithPath: lhs)
        let rhsURL = URL(fileURLWithPath: rhs)
        return lhsURL.lastPathComponent > rhsURL.lastPathComponent
      })
    return (contents ?? [])
      .map { url.appendingPathComponent($0) }
      .map(Template.init)
  }
}

// MARK: -

struct CopyTemplate {
  let template: Template
  let dateFormat = "yyyyMMdd"
  let fileManager = FileManager.default
  
  var intermediateDirectoryName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    // folder name
    return formatter.string(from: Date())
  }
  
  func createIntermediateDirectory(to: URL) -> Bool {
    let folder = to.appendingPathComponent(intermediateDirectoryName)
    let fileExists = fileManager.fileExists(atPath: folder.path)
    if !fileExists {
      try! fileManager.createDirectory(atPath: folder.path, withIntermediateDirectories: true, attributes: nil)
    }
    return !fileExists
  }
    
  func copyIfNeeded(to folder: URL) -> URL {
    // input
    let templateName = template.url.lastPathComponent
    print("Template: \(templateName)")
    // output
    _ = createIntermediateDirectory(to: folder)
    //
    let intermediateDirectory = folder.appendingPathComponent(intermediateDirectoryName)
    let destination = intermediateDirectory.appendingPathComponent(templateName)
    print("Destination: \(destination)")
    // check if exists
    if !fileManager.fileExists(atPath: destination.path) {
      print("File not found: create a new one")
      try! fileManager.copyItem(at: template.url, to: destination)
    } else {
      print("Found file.")
    }
    return destination
  }
}

extension CopyTemplate {
  init(_ path: String) {
    self.init(template: Template(path))
  }
}
