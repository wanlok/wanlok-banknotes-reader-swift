//
//  getXMLAttributeValues.swift
//  banknotes-reader
//
//  Created by Robert Wan on 2/11/2025.
//

private func createEmptyValues(_ attributeNames: [String]) -> [String: [String]] {
    var values: [String: [String]] = [:]
    for attributeName in attributeNames {
        values[attributeName] = []
    }
    return values
}

private class XMLAttributeValuesParserDelegate: NSObject, XMLParserDelegate {
    var values: [String: [String]] = [:]
    
    private var elementName: String
    private var attributeNames: [String]
    
    init(elementName: String, attributeNames: [String]) {
        self.elementName = elementName
        self.attributeNames = attributeNames
        values = createEmptyValues(attributeNames)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard elementName == self.elementName else {
            return
        }
        for attributeName in attributeNames {
            if let value = attributeDict[attributeName] {
                values[attributeName]?.append(value)
            }
        }
    }
}

func getXMLAttributeValues(filePath: URL, elementName: String, attributeNames: [String]) -> [String: [String]] {
    guard let data = try? Data(contentsOf: filePath) else {
        return createEmptyValues(attributeNames)
    }
    let parser = XMLParser(data: data)
    let delegate = XMLAttributeValuesParserDelegate(elementName: elementName, attributeNames: attributeNames)
    parser.delegate = delegate
    parser.parse()
    return delegate.values
}
