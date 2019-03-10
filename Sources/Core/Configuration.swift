import Foundation

struct Configuration: Codable {
  let target: Foundation.URL
  let templates: Foundation.URL
  let pathExtension: String
}

extension Configuration: CustomStringConvertible {
  var description: String {
    var instance = ""
    instance.append("target       : \(target.path)\n")
    instance.append("templates    : \(templates.path)\n")
    instance.append("pathExtension: \(pathExtension)\n")
    return instance
  }
}

enum StoreError: Error {
  case configurationNotFound
}

extension StoreError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .configurationNotFound:
      return NSLocalizedString("Configuration not found. Please run configure first.", comment: "")
    }
  }
}

struct Store {
  let folder = ".playground-butler"
  let filename = "config"
  let url: URL
  static var `default` = Store(URL(fileURLWithPath: NSHomeDirectory()))
  private let fileManager = FileManager.default
  
  init(_ base: URL) {
    self.url = base
      .appendingPathComponent(folder)
      .appendingPathComponent(filename)
  }
  
  func configuration() throws -> Configuration {
    guard fileManager.fileExists(atPath: url.path) else {
      throw StoreError.configurationNotFound
    }
    let data = try Data(contentsOf: url)
    let decoded = try JSONDecoder().decode(Configuration.self, from: data)
    return decoded
  }
  
  func save(_ configuration: Configuration) throws {
    let folder = url.deletingLastPathComponent()
    if !fileManager.fileExists(atPath: folder.path) {
      try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
    }
    let encoded = try JSONEncoder().encode(configuration)
    try encoded.write(to: url)
  }
}
