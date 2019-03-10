//
//  TemplateTests.swift
//  Playground-ButlerTests
//
//  Created by Marco Meschini on 09/03/2019.
//

import XCTest
@testable import Core

class TemplateTests: XCTestCase {

  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    _ = templatePath
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
    removeTemplate()
  }

  func test_init() {
    var template = Template(url: templatePath)
    XCTAssertNotNil(template)
    XCTAssertEqual(template.url, templatePath)
    template = Template(templatePath.path)
    XCTAssertNotNil(template)
    XCTAssertEqual(template.url, templatePath)
  }

  func test_intermediateDirectory() {
    let template = Template(url: templatePath)
    let copy = CopyTemplate(template: template)
    let formatter = DateFormatter()
    formatter.dateFormat = copy.dateFormat
    XCTAssertEqual(formatter.string(from: Date()), copy.intermediateDirectoryName)
  }
  
  func test_createIntermediateDirectory_return_true() {
    let template = Template(url: templatePath)
    let copy = CopyTemplate(template: template)
    let testBundle = Bundle(for: type(of: self))
    let directory = testBundle.bundleURL.appendingPathComponent(copy.intermediateDirectoryName)
    try! FileManager.default.removeItem(at: directory)
    XCTAssertTrue(copy.createIntermediateDirectory(to: testBundle.bundleURL))
  }
  
  func test_createIntermediateDirectory_return_false() {
    let template = Template(url: templatePath)
    let copy = CopyTemplate(template: template)
    let testBundle = Bundle(for: type(of: self))
    let directory = testBundle.bundleURL.appendingPathComponent(copy.intermediateDirectoryName)
    try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    XCTAssertFalse(copy.createIntermediateDirectory(to: testBundle.bundleURL))
  }
  
  private var templatePath: URL {
    let testBundle = Bundle(for: type(of: self))
    let url = testBundle.bundleURL.appendingPathComponent("Template.playground")
    if !FileManager.default.fileExists(atPath: url.path) {
      let data = Data()
      try! data.write(to: url)
    }
    return url
  }
  
  private func removeTemplate() {
    let testBundle = Bundle(for: type(of: self))
    let url = testBundle.bundleURL.appendingPathComponent("Template.playground")
    try! FileManager.default.removeItem(at: url)
  }
}
