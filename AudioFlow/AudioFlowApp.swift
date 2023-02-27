//
//  AudioFlowApp.swift
//  AudioFlow
//
//  Created by Antonio Esposito on 27/02/23.
//

import SwiftUI

@main
struct AudioFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
