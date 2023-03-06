//
//  OfficialAPI.swift
//  MC3-Invisible
//
//  Created by Ravi  on 2/21/23.
//

import Foundation

class trackGenerationAPI {
    
    struct TrackAPIResponse: Codable {
        let method, apiVer: String
        let status: Int
        let data: DataClass
        
        enum CodingKeys: String, CodingKey {
            case method
            case apiVer = "api_ver"
            case status, data
        }
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let tasks: [Task]
    }
    
    // MARK: - Task
    struct Task: Codable {
        let taskID: String
        let taskStatusCode: Int
        let taskStatusText: String
        let downloadLink: URL
        
        enum CodingKeys: String, CodingKey {
            case taskID = "task_id"
            case taskStatusCode = "task_status_code"
            case taskStatusText = "task_status_text"
            case downloadLink = "download_link"
        }
    }
    
    typealias TrackAPIResult = Result<TrackAPIResponse, Error>
    
    let url = URL(string: "https://api-b2b.mubert.com/v2/TTMRecordTrack")!
    
    func generateTrack(input: String, pat: String, duration: Int, completion: @escaping (TrackAPIResult) -> Void) {
        let parameters: [String: Any] = [
            "method": "TTMRecordTrack",
            "params": [
                "text": input,
                "pat": pat,
                "duration": duration
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let data = data else {
                completion(.failure(MyError.networkError))
                return
            }
            guard let parsed = try? JSONDecoder().decode(TrackAPIResponse.self, from: data) else {
                completion(.failure(MyError.parsingError))
                return
            }
            completion(.success(parsed))
        }
        task.resume()
    }
    
    enum MyError: Error {
        case networkError
        case parsingError
    }
}

