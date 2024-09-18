
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var appState = appState
        VStack(alignment: .leading) {
            HStack {
                Text("3D Charts")
                    .font(.extraLargeTitle)
                    .padding(.bottom, Constants.verticalSpacing)
                Spacer()
                Toggle(isOn: $appState.isShowingChart) {
                    if appState.isShowingChart {
                        Text("Hide Chart")
                            .frame(minWidth: 160)
                    } else {
                        Text("Show Chart")
                            .frame(minWidth: 160)
                    }
                }
                .toggleStyle(.button)
            }
            TextField("Chart Title", text: $appState.chartTitle)
                .font(.title)
                .frame(maxWidth: 480)
                .padding(.bottom, Constants.verticalSpacing)
            Spreadsheet()
                .padding(.bottom, Constants.verticalSpacing)
        }
        .fixedSize()
        .padding(EdgeInsets(top: Constants.verticalSpacing,
                            leading: Constants.horizontalMargin,
                            bottom: Constants.verticalSpacing,
                            trailing: Constants.horizontalMargin))
    }
}

#Preview {
    let appState = AppState()
    appState.preloadAppState()
    return ContentView()
        .glassBackgroundEffect()
        .environment(appState)
}
