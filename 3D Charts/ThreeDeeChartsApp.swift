
import SwiftUI

@main
struct ThreeDeeChartsApp: App {
    @State private var appState: AppState = {
        let appState = AppState()
        #if DEBUG
        appState.preloadAppState()
        #endif
        return appState
    }()
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onChange(of: appState.isShowingChart) { oldValue, newValue in
                    if newValue {
                        openWindow(id: .chartWindow)
                    } else {
                        dismissWindow(id: .chartWindow)
                    }
                }
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: .chartWindow) {
            ChartView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.5, depth: 0.8, in: .meters)
    }
}

typealias WindowId = String

extension WindowId {
    static let chartWindow = "ChartWindow"
}
