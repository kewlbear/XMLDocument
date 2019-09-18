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

import Foundation
import libxml2XMLDocument

func todo() {
    fatalError()
}

public enum XMLError: Error {
    case invalidStringEncoding
    case noMemory
    case libxml2
}

open class XMLDocument: XMLNode {
    open var xmlData: Data {
        todo()
        return Data()
    }
    
    let docPtr: xmlDocPtr?
    
    @objc
    public init(data: Data, options: Int) throws {
        let encoding: String.Encoding = .utf8
        let xml = String(data: data, encoding: encoding)
        
        guard let charsetName = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) as String?,
            let cur = xml?.cString(using: encoding) else {
                throw XMLError.invalidStringEncoding
        }
        let url: String = ""
        let option = 0
        // FIXME: xmlParseMemory?
        docPtr = xmlReadDoc(UnsafeRawPointer(cur).assumingMemoryBound(to: xmlChar.self), url, charsetName, CInt(option))
        
        super.init(nodePtr: nil, owner: nil)
    }
    
    public convenience init(xmlString: String, options: Int) throws {
        guard let data = xmlString.data(using: .utf8) else { fatalError() }
        
        try self.init(data: data, options: options)
    }
    
    open func rootElement() -> XMLElement? {
        let root = docPtr.flatMap { xmlDocGetRootElement($0) }
        return root.map { XMLElement(nodePtr: $0, owner: self) }
    }
}

open class XMLElement: XMLNode {
    
    public convenience init(name: String, stringValue string: String? = nil) {
        let node = xmlNewNode(nil, name)
        assert(node != nil)
        
        self.init(nodePtr: node, owner: nil)
        
        stringValue = string
    }
    
    override init(nodePtr: xmlNodePtr?, owner: XMLNode?) {
        super.init(nodePtr: nodePtr, owner: owner)
    }
    
    open func attribute(forName name: String) -> XMLNode? {
        var _attr = nodePtr?.pointee.properties
        
        repeat {
            guard let attr = _attr else {
                break
            }

            if attr.pointee.ns != nil && attr.pointee.ns.pointee.prefix != nil {
                if xmlStrQEqual(attr.pointee.ns.pointee.prefix, attr.pointee.name, name) != 0 {
                    return nil // FIXME: attr
                }
            } else {
                if xmlStrEqual(attr.pointee.name, name) != 0 {
                    return nil // FIXME: attr
                }
            }
            
            _attr = attr.pointee.next
        } while _attr != nil
        
        return nil
    }
    
    open func addChild(_ child: XMLNode) {
        todo()
    }
    
    open func addAttribute(_ attribute: XMLNode) {
        todo()
    }
    
    open func removeAttribute(forName name: String) {
        todo()
    }
}

open class XMLNode {
    open class func element(withName name: String) -> Any {
        return ""
    }
    
    open class func element(withName name: String, stringValue string: String) -> Any {
        return ""
    }
    
    open class func attribute(withName name: String, stringValue: String) -> Any {
        return ""
    }
    
    open class func text(withStringValue stringValue: String) -> Any {
        return ""
    }
    
    open var stringValue: String? {
        get {
            return nodePtr.flatMap {
                let content = xmlNodeGetContent($0)
                defer {
                    xmlFree(content)
                }
                return content.flatMap { String(utf8String: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self)) }
            }
        }
        
        set {
            guard let node = nodePtr else { fatalError() }
            let escaped = xmlEncodeSpecialChars(node.pointee.doc, newValue ?? "")
            xmlNodeSetContent(node, escaped)
            xmlFree(escaped)
        }
    }
    
    open var children: [XMLNode]?
    
    open var name: String?
    
    open var xmlString: String {
        return ""
    }
    
    open var parent: XMLNode? {
        return nil
    }
    
    let nodePtr: xmlNodePtr?
    
    var owner: XMLNode?
    
    init(nodePtr: xmlNodePtr?, owner: XMLNode?) {
        self.nodePtr = nodePtr
        self.owner = owner
    }
    
    deinit {
        if owner == nil, let node = nodePtr {
            xmlFreeNode(node)
        }
    }
    
    open func nodes(forXPath xpath: String) throws -> [XMLNode] {
        let ctxt = nodePtr.flatMap { xmlXPathNewContext($0.pointee.doc) }
        if ctxt == nil {
            throw XMLError.noMemory
        }
        ctxt?.pointee.node = nodePtr
        
//        if let nsDictionary = namespaces {
//            for (ns, name) in nsDictionary {
//                xmlXPathRegisterNs(ctxt, ns, name)
//            }
//        }
        
        let result = xmlXPathEvalExpression(xpath, ctxt)
        defer {
            xmlXPathFreeObject(result)
        }
        xmlXPathFreeContext(ctxt)
        
        guard let nodeSet = result?.pointee.nodesetval else {
            throw XMLError.libxml2
        }
        
        let count = Int(nodeSet.pointee.nodeNr)
        guard count > 0 else {
            return []
        }
        
        var nodes: [XMLNode] = []
        
        for index in 0..<count {
            guard let node = nodeSet.pointee.nodeTab?[index] else {
                throw XMLError.libxml2
            }
            nodes.append(XMLNode(nodePtr: node, owner: self))
        }
        
        return nodes
    }
    
    open func detach() {
        
    }
}
