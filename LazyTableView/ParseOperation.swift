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
    private var workingArray: [AppRecord] = []
    private var workingEntry: AppRecord?
    private var workingPropertyString: String = ""
    private var storingCharacterData: Bool = false
    
    init(data: Data) {
        dataToParse = data
        elementsToParse = [kIDStr, kNameStr, kImageStr, kArtistStr, kEntryStr]
    }
    
    override func main() {
        workingArray = []
        workingPropertyString = ""
        let parser = XMLParser(data: self.dataToParse)
        parser.delegate = self
        parser.parse()
        
        if !self.isCancelled {
            self.appRecordList = self.workingArray
        }
        
        self.workingArray = []
        self.workingPropertyString = ""
        self.dataToParse = Data()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == kEntryStr {
            self.workingEntry = AppRecord()
        }
        self.storingCharacterData = self.elementsToParse.index(of: elementName) != nil
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let workingEntry = self.workingEntry {
            if self.storingCharacterData {
                let trimmedString = self.workingPropertyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                self.workingPropertyString = ""
                switch elementName {
                case kIDStr:
                    workingEntry.appURLString = trimmedString
                case kNameStr:
                    workingEntry.appName = trimmedString
                case kImageStr:
                    workingEntry.imageURLString = trimmedString
                case kArtistStr:
                    workingEntry.artist = trimmedString
                default:
                    break
                }
            } else if elementName == kEntryStr {
                workingArray.append(workingEntry)
                self.workingEntry = nil
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if storingCharacterData {
            self.workingPropertyString += string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.errorHandler?(parseError)
    }
  
}
