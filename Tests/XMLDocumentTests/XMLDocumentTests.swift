//
//  Copyright (c) 2019 Changbeom Ahn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
@testable import JebiXML

final class XMLDocumentTests: XCTestCase {
    let hello = """
        <?xml version="1.0" encoding="UTF-8"?>
        <x a="y">Hello, World!</x>
        
        """
    
    func testInitWithData() {
        XCTAssertEqual(
            try document(content: hello).rootElement()?.stringValue,
            "Hello, World!")
    }

    func testNodesForXPath() {
        XCTAssertEqual(
            try document(content: hello).nodes(forXPath: "/").first?.stringValue,
            "Hello, World!")
    }
    
    func testReturnsElement() throws {
        let x = try document(content: hello).nodes(forXPath: "/*").first
        XCTAssertEqual(
            (x as? XMLElement)?.attribute(forName: "a")?.stringValue,
            "y")
    }
    
    func testXMLString() {
        XCTAssertEqual(
            try document(content: hello).nodes(forXPath: "/").first?.xmlString,
            hello)
    }
    
    func testChildren() {
        XCTAssertEqual(
            try document(content: hello).children?.count,
            1)
    }
    
    func testName() {
        XCTAssertEqual(
            try document(content: hello).rootElement()?.name,
            "x")
    }
    
    func testParent() {
        XCTAssertEqual(
            try document(content: hello).nodes(forXPath: "//text()").first?.parent?.name,
            "x")
    }
        
    func testDetach() throws {
        let node = try document(content: hello).nodes(forXPath: "//text()").first!
        node.detach()
        XCTAssertNil(node.parent)
    }
    
    func testElementWithName() {
        let element = XMLNode.element(withName: "a") as! XMLElement
        XCTAssertEqual(element.name, "a")
    }
    
    func testElementWithNameStringValue() {
        let element = XMLNode.element(withName: "a", stringValue: "v") as! XMLElement
        XCTAssertEqual(element.name, "a")
        XCTAssertEqual(element.stringValue, "v")
    }
    
    func testAttributeWithNameStringValue() {
        let attribute = XMLNode.attribute(withName: "a", stringValue: "v") as! XMLNode
        XCTAssertEqual(attribute.name, "a")
        XCTAssertEqual(attribute.stringValue, "v")
    }
    
    func testTextWithStringValue() {
        let text = XMLNode.text(withStringValue: "text") as! XMLNode
        XCTAssertEqual(text.stringValue, "text")
    }
    
    func testAddChild() {
        let element = XMLNode.element(withName: "e") as! XMLElement
        element.addChild(XMLNode.text(withStringValue: "t") as! XMLNode)
        XCTAssertEqual(element.children?.count, 1)
    }
    
    func testAddAttribute() {
        let element = XMLNode.element(withName: "e") as! XMLElement
        let name = "n"
        let value = "v"
        element.addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
        XCTAssertEqual(element.attribute(forName: name)?.stringValue, value)
    }
    
    func testRemoveAttribute() {
        let element = XMLNode.element(withName: "e") as! XMLElement
        let name = "n"
        let value = "v"
        element.addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
        element.removeAttribute(forName: name)
        XCTAssertNil(element.attribute(forName: name))
    }
    
    static var allTests = [
        ("testInitWithData", testInitWithData),
        ("testNodesForXPath", testNodesForXPath),
        ("testReturnsElement", testReturnsElement),
        ("testXMLString", testXMLString),
        ("testChildren", testChildren),
        ("testName", testName),
        ("testParent", testParent),
        ("testDetach", testDetach),
        ("testElementWithName", testElementWithName),
        ("testElementWithNameStringValue", testElementWithNameStringValue),
        ("testAttributeWithNameStringValue", testAttributeWithNameStringValue),
        ("testTextWithStringValue", testTextWithStringValue),
        ("testAddAttribute", testAddAttribute),
        ("testRemoveAttribute", testRemoveAttribute),
    ]
    
    func document(content: String) throws -> XMLDocument {
        try XMLDocument(data: content.data(using: .utf8)!, options: 0)
    }
}
