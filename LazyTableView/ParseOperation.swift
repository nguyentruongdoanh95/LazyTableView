//
//  ParseOperation.swift
//  LazyTableView
//
//  Created by Godfather on 3/20/17.
//  Copyright © 2017 Godfather. All rights reserved.
//

import Foundation


class ParseOperation: Operation, XMLParserDelegate {
    
    var errorHandler: ((Error) -> Void)?
    var appRecordList: [AppRecord]?
    let kIDStr = "id"
    let kNameStr = "im:name"
    let kImageStr = "im:image"
    let kArtistStr = "im:artist"
    let kEntryStr = "entry"
    
    private var dataToParse: Data
    private var elementsToParse: [String]
    init(data: Data) {
        dataToParse = data
        elementsToParse = [kIDStr, kNameStr, kImageStr, kArtistStr, kEntryStr]
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }
}
