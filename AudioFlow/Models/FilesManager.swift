//
//  FilesListManager.swift
//  AudioFlow
//
//  Created by Ravi on 3/3/23.
//

import Foundation

class FilesManager: ObservableObject {
    @Published var files: [FileInfo] = []
    
    init() {
        files = getFiles()
    }
    
    func refreshFiles(){
        files = getFiles()
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func deleteFile(_ file: FileInfo) {
        do {
            try FileManager.default.removeItem(at: file.path)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    func getFiles() -> [FileInfo] {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl = documentsUrl.appendingPathComponent("mp3JamBotFiles")
        
        var fileInfos: [FileInfo] = []
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            for file in files {
                if file.lastPathComponent.starts(with: ".DS_Store") {
                    continue // Ignore .DS_Store file
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
                let filename = file.lastPathComponent
                if let date = dateFormatter.date(from: String(filename.prefix(16))) {
                    let input = String(filename.dropFirst(17).dropLast(4)).replacingOccurrences(of: "-", with: " ")
                    let fileInfo = FileInfo(input: input, date: formatDate(date), path: file)
                    fileInfos.append(fileInfo)
                } else {
                    fatalError("Error parsing date from file name: \(filename)")
                }
            }
        } catch {
            print(error)
        }
        return fileInfos
    }
}
