
import SwiftUI
import RealityKit
import RealityKitContent

struct ChartView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            content.add(appState.chart)
        } update: { content in
            appState.updateChart()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Text(appState.chartTitle)
                }
            }
        }
        .onDisappear {
            appState.isShowingChart = false
        }
    }
    
    private func loadEntity() async -> Entity? {
        try? await Entity(named: "Scene", in: realityKitContentBundle)
    }
}

#Preview(windowStyle: .volumetric) {
    ChartView()
        .environment(AppState())
}
