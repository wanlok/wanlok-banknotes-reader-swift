//
//  getXMLAttributeValues.swift
//  banknotes-reader
//
//  Created by Robert Wan on 2/11/2025.
//

private class XMLAttributeValueParserDelegate: NSObject, XMLParserDelegate {
    var values: [String] = []
    
    private var elementName: String
    private var attributeName: String
    
    init(elementName: String, attributeName: String) {
        self.elementName = elementName
        self.attributeName = attributeName
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == self.elementName, let value = attributeDict[attributeName] {
            values.append(value)
        }
    }
}

func getXMLAttributeValues(filePath: String, elementName: String, attributeName: String) -> [String] {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        return []
    }
    let parser = XMLParser(data: data)
    let delegate = XMLAttributeValueParserDelegate(elementName: elementName, attributeName: attributeName)
    parser.delegate = delegate
    parser.parse()
    return delegate.values
}
