
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var appState = appState
        VStack(alignment: .leading) {
            Text("3D Charts")
                .font(.extraLargeTitle)
                .padding(.bottom, Constants.verticalSpacing)
            TextField("Chart Title", text: $appState.chartTitle)
                .font(.title)
                .frame(maxWidth: 480)
                .padding(.bottom, Constants.verticalSpacing)

        }
        .padding(EdgeInsets(top: Constants.verticalSpacing,
                            leading: Constants.horizontalMargin,
                            bottom: Constants.verticalSpacing,
                            trailing: Constants.horizontalMargin))
    }
}

#Preview {
    return ContentView()
        .glassBackgroundEffect()
        .environment(AppState())
}
