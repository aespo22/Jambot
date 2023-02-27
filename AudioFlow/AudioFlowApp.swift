//
//  AudioFlowApp.swift
//  AudioFlow
//
//  Created by Antonio Esposito on 27/02/23.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}

@main
struct AudioFlow: App {
    let networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            HistoryView()
        }
    }
}
