//
//  Util.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/12.
//

import Foundation

func decodeWastJSON(fileName: String) -> Wast? {
    let fileURL = Bundle.module.url(forResource: fileName, withExtension: "json")!
    let filePath = fileURL.path
    guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
        return nil
    }
    defer { fileHandle.closeFile() }

    do {
        guard let data = try fileHandle.readToEnd() else {
            return nil
        }

        return try JSONDecoder().decode(Wast.self, from: data)
    } catch {
        print(error)
        return nil
    }
}

func parseWastJSON(fileName: String) -> Wast? {
    let fileURL = Bundle.module.url(forResource: fileName, withExtension: "json")!
    let filePath = fileURL.path
    guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
        return nil
    }
    defer { fileHandle.closeFile() }

    do {
        guard let data = try fileHandle.readToEnd() else {
            return nil
        }

        return try JSONDecoder().decode(Wast.self, from: data)
    } catch {
        print(error)
        return nil
    }
}
