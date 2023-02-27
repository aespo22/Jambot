import Foundation


func trackStatus(downloadLink: String, pat: String, completion: @escaping (Bool) -> Void) {
    let urlString = "https://api-b2b.mubert.com/v2/TrackStatus"
    let payload = [
        "method": "TrackStatus",
        "api_ver": "api-b2b_2.2",
        "params": [
            "pat": pat
        ]
    ] as [String : Any]
    
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
        print("Failed to create HTTP request body")
        completion(false)
        return
    }
    request.httpBody = httpBody
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown Error")")
            completion(false)
            return
        }
        
        do {
            let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//            print("Response JSON: \(responseJson)")
            
            guard let data = responseJson["data"] as? [String: Any], let tasks = data["tasks"] as? [[String: Any]] else {
                print("Failed to parse tasks from response data")
                completion(false)
                return
            }
            
            var isDownloadLinkFound = false
            for task in tasks {
                if let taskStatus = task["task_status_code"] as? Int, taskStatus == 2,
                   let taskLink = task["download_link"] as? String, taskLink == downloadLink {
                    isDownloadLinkFound = true
                    break
                }
            }
            
            if isDownloadLinkFound {
                completion(true)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                trackStatus(downloadLink: downloadLink, pat: pat, completion: completion)
            }
            
        } catch let error {
            print("Error parsing response: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    task.resume()
}
