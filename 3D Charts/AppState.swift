
import Foundation

@Observable
public class AppState {
    var chartTitle: String = ""
    var chartContent: ChartContent = []
}

#if DEBUG
extension AppState {
    func preloadAppState() {
        chartTitle = "Favourite Colour by Age"
        chartContent = [
            ChartRow(data: [ChartData(value: "Age Range"),
                            ChartData(value: "1-20"),
                            ChartData(value: "21-40"),
                            ChartData(value: "41-60"),
                            ChartData(value: "61-80")]),
            ChartRow(data: [ChartData(value: "Red"),
                            ChartData(value: "15"),
                            ChartData(value: "55"),
                            ChartData(value: "16"),
                            ChartData(value: "12")]),
            ChartRow(data: [ChartData(value: "Yellow"),
                            ChartData(value: "5"),
                            ChartData(value: "15"),
                            ChartData(value: "38"),
                            ChartData(value: "40")]),
            ChartRow(data: [ChartData(value: "Green"),
                            ChartData(value: "20"),
                            ChartData(value: "20"),
                            ChartData(value: "32"),
                            ChartData(value: "18")]),
            ChartRow(data: [ChartData(value: "Blue"),
                            ChartData(value: "60"),
                            ChartData(value: "10"),
                            ChartData(value: "14"),
                            ChartData(value: "30")]),
        ]
    }
}
#endif
