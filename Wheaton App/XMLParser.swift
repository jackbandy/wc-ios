//
//  XMLParser.swift
//  Wheaton App
//
//  Created by Jack Work on 7/1/15.
//
//  NOTICE: Ported to Swift 5 by an LLM (Claude Code), 2026-10-11. The class was
//  renamed to RSSFeedParser because Foundation now ships its own XMLParser.
//

import Foundation

class RSSFeedParser: NSObject, XMLParserDelegate {

    var arrParsedData = [[String: String]]()

    private var currentDataDictionary = [String: String]()
    private var currentElement = ""
    private var foundCharacters = ""

    func startParsingWithContentsOfURL(_ rssURL: URL) {
        guard let parser = XMLParser(contentsOf: rssURL) else { return }
        parser.delegate = self
        parser.parse()
    }

    // MARK: XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let value = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        if !value.isEmpty {
            currentDataDictionary[currentElement] = value
            foundCharacters = ""
            if currentElement == "pubDate" {
                arrParsedData.append(currentDataDictionary)
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "title" || currentElement == "link" || currentElement == "pubDate" {
            foundCharacters += string
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
