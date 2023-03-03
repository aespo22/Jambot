
import Foundation
import CoreData

class DownloadManager {
    func saveMp3ToPhone(input: String, url: URL, completion: @escaping () -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateStr = dateFormatter.string(from: Date())
        
        var formattedInput = input.replacingOccurrences(of: " ", with: "-")
        formattedInput = formattedInput.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? formattedInput
        
        let fileName = "\(dateStr)_\(formattedInput).mp3"
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderUrl = documentsUrl.appendingPathComponent("mp3JamBotFiles")
        if !FileManager.default.fileExists(atPath: folderUrl.path) {
            do {
                try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error.localizedDescription)")
                return
            }
        }
        let destinationUrl = folderUrl.appendingPathComponent(fileName)
        
        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationUrl)
                    print("File saved at \(destinationUrl)")
                    completion()

                } catch (let writeError) {
                    print("Error creating a file \(destinationUrl) : \(writeError)")
                }
            } else {
                print("Error downloading file: \(error?.localizedDescription ?? "")")
            }
        }
        
        task.resume()
    }
}
