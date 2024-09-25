//
//  MedicallyApp.swift
//  Shared
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI

@main
struct MedicallyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
