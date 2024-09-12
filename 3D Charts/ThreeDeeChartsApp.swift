
import SwiftUI

@main
struct ThreeDeeChartsApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        
        WindowGroup {
            // 3D charts will go here
        }.windowStyle(.volumetric)
    }
}
