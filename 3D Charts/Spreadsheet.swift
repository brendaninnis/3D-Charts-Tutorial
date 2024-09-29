
import SwiftUI

struct Spreadsheet: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Grid(alignment: .leading,
             horizontalSpacing: Constants.cellBorderWidth,
             verticalSpacing: Constants.cellBorderWidth)
        {
            ForEach(Array(appState.chartContent.enumerated()),
                    id: \.offset)
            { rowIndex, row in

                GridRow {
                    ForEach(Array(row.data.enumerated()),
                            id: \.offset)
                    { _, data in

                        @Bindable var data = data
                        TextField("", text: $data.value)
                            .frame(width: Constants.cellWidth,
                                   height: Constants.cellHeight)
                    }
                }

                if rowIndex == 0 {
                    Divider()
                        .gridCellUnsizedAxes(.horizontal)
                        .padding(EdgeInsets(top: 0,
                                            leading: 4,
                                            bottom: 0,
                                            trailing: 4))
                }
            }
        }
    }
}

private extension Constants {
    static let cellBorderWidth: CGFloat = 4
    static let cellWidth: CGFloat = 100
    static let cellHeight: CGFloat = 32
}

#Preview {
    let appState = AppState()
    appState.preloadAppState()
    return Spreadsheet()
        .padding(EdgeInsets(top: 8, leading: 48, bottom: 8, trailing: 48))
        .glassBackgroundEffect()
        .environment(appState)
}
