import XCTest
import Foundation
@testable import Core

class StoreTests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func test_configuration_return_nil() throws {
    let testBundle = Bundle(for: type(of: self))
    let store = Store(testBundle.bundleURL)
    XCTAssertThrowsError(try store.configuration())
  }
  
  func test_configuration_return_valid_configuration() throws {
    let base = Bundle(for: type(of: self)).bundleURL
    let configuration = Configuration(target: base, templates: base, pathExtension: "foo")
    let store = Store(base)
    try store.save(configuration)
    XCTAssertNotNil(store.configuration)
    try? FileManager.default.removeItem(at: store.url)
  }
  
  func test_save() throws {
    let base = Bundle(for: type(of: self)).bundleURL
    let store = Store(base)
    XCTAssertThrowsError(try store.configuration())
    let configuration = Configuration(target: base, templates: base, pathExtension: "foo")
    try store.save(configuration)
    XCTAssertNotNil(try store.configuration())
    try? FileManager.default.removeItem(at: store.url)
  }
}
