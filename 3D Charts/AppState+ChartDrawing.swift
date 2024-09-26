
import Foundation
import UIKit
import RealityKit

fileprivate extension ChartContent {
    var maxChartValue: Float {
        var result: Float = 0
        // Drop headings
        for row in dropFirst() {
            for col in row.data.dropFirst() {
                result = Swift.max(result, col.floatValue)
            }
        }
        if result <= 0 {
            result = 1
        }
        return result
    }
}

fileprivate var chartBoundsDidChange = true

extension AppState {
    /// The width and depth of a bar in meters
    private var barSize: Float { 0.05 }
    /// The height of a bar in meters
    private var barHeight: Float { barSize * 5 }
    /// The size of the gutters in between the bars
    private var barPadding: Float { barSize * 0.5 }
    /// The minimum height of a bar
    private var minBarScale: Float { 0.042 }
    
    private enum ChartColors {
        case red
        case yellow
        case green
        case blue
        
        var uiColor: UIColor {
            switch self {
            case .red:
                return .red
            case .yellow:
                return .yellow
            case .green:
                return .green
            case .blue:
                return .blue
            }
        }
                
        static var all: [ChartColors] {
            [
                .red,
                .yellow,
                .green,
                .blue,
            ]
        }
    }

    func updateChart() {
        // Calculate the greatest value to determine the height of the chart
        let maxChartValue = chartContent.maxChartValue
        
        chartContent.dropFirst().enumerated().forEach { rowIndex, row in
            draw(chartRow: row,
                 maxChartValue: maxChartValue,
                 rowIndex: rowIndex)
        }
        
        if chartBoundsDidChange {
            let bounds = chart.visualBounds(relativeTo: nil).extents
                        
            // Position the chart in the middle of the volumne
            chart.transform.translation.x = -1 * bounds.x * 0.5
            chart.transform.translation.z = -1 * bounds.z * 0.5
            
            chartBoundsDidChange = false
        }
    }
    
    private func draw(chartRow row: ChartRow,
                      maxChartValue: Float,
                      rowIndex: Int) {
        let color = ChartColors.all[rowIndex].uiColor
        
        row.data.dropFirst().enumerated().forEach { colIndex, data in
            // Determines the height of the bar
            let scale = max(data.floatValue / maxChartValue, minBarScale)
            
            drawCell(data: data,
                     scale: scale,
                     color: color,
                     rowIndex: rowIndex,
                     colIndex: colIndex)
        }
    }
    
    private func drawCell(data: ChartData,
                          scale: Float,
                          color: UIColor,
                          rowIndex: Int,
                          colIndex: Int) {
        // Create the entity if needed
        let entity = data.entity ?? {
            chartBoundsDidChange = true

            // Create a model entity for the bar
            let mesh = MeshResource.generateBox(width: barSize,
                                                height: barHeight,
                                                depth: barSize)
            let colorMaterial = SimpleMaterial(color: color,
                                               roughness: 0.3,
                                               isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [colorMaterial])
            
            // Set the height of the bar
            entity.transform.scale.y = scale
            // Align the bars vertically
            entity.transform.translation.y = barHeight * scale * 0.5
 
            // Position the bar in row and column position
            let x = (barSize + barPadding) * Float(colIndex) + barSize * 0.5
            let z = (barSize + barPadding) * Float(rowIndex) + barSize * 0.5
            entity.transform.translation.x = x
            entity.transform.translation.z = z
            
            // Add the entity to the chart
            chart.addChild(entity)
            
            // Store the new entity in this ChartData
            data.entity = entity
            
            return entity
        }()

        // Change the height of the bar if needed
        if entity.transform.scale.y != scale {
            var transform = entity.transform
            transform.scale.y = scale
            transform.translation.y = barHeight * scale * 0.5
            // Animate the bar height changes
            let anim = FromToByAnimation(from: entity.transform,
                                         to: transform,
                                         bindTarget: .transform)
            if let res = try? AnimationResource.generate(with: anim) {
                entity.playAnimation(res)
            }
        }
    }
}
