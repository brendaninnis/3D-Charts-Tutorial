
import Foundation

/// Represents a cell in the chart
@Observable
class ChartData {
    /// The value held this cell in the chart
    var value: String
    /// The value as a `Float` or `0` if not a number
    var floatValue: Float {
        Float(value) ?? 0
    }
    
    init(value: String) {
        self.value = value
    }
}

/// Represents a row of chart data
@Observable
class ChartRow {
    /// The data held in each column of this row
    var data: [ChartData]
    
    init(data: [ChartData]) {
        self.data = data
    }
}

/// Represents all the data held in the chart
typealias ChartContent = [ChartRow]
