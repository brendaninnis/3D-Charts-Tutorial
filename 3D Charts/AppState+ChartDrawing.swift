
import Foundation
import RealityKit
import UIKit

private extension ChartContent {
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

private var chartBoundsDidChange = true

extension AppState {
    /// The width and depth of a bar in meters
    private var barSize: Float { 0.05 }
    /// The height of a bar in meters
    private var barHeight: Float { barSize * 5 }
    /// The size of the gutters in between the bars
    private var barPadding: Float { barSize * 0.5 }
    /// The minimum height of a bar
    private var minBarScale: Float { 0.042 }
    /// The distance between the edge of the base plate and the chart content
    private var basePlatePadding: Float { 0.1 }
    /// The thickness of the base plate
    private var basePlateHeight: Float { 0.02 }

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

        for (rowIndex, row) in chartContent.dropFirst().enumerated() {
            draw(chartRow: row,
                 maxChartValue: maxChartValue,
                 rowIndex: rowIndex)
        }

        if chartBoundsDidChange {
            let bounds = chart.visualBounds(relativeTo: nil).extents

            drawBasePlate(inBounds: bounds)

            // Position the middle of the chart in the middle of the volumne
            chart.transform.translation.x = -1 * bounds.x * 0.5
            chart.transform.translation.z = -1 * bounds.z * 0.5

            chartBoundsDidChange = false
        }
    }

    private func draw(chartRow row: ChartRow,
                      maxChartValue: Float,
                      rowIndex: Int)
    {
        let color = ChartColors.all[rowIndex].uiColor

        for (colIndex, data) in row.data.dropFirst().enumerated() {
            // Determines the height of the bar
            let scale = max(data.floatValue / maxChartValue, minBarScale)

            drawCell(data: data,
                     scale: scale,
                     color: color,
                     rowIndex: rowIndex,
                     colIndex: colIndex)
        }

        drawHeading(forChartRow: row, rowIndex: rowIndex)
    }

    private func drawCell(data: ChartData,
                          scale: Float,
                          color: UIColor,
                          rowIndex: Int,
                          colIndex: Int)
    {
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

    private func drawHeading(forChartRow row: ChartRow, rowIndex: Int) {
        guard let heading = row.data.first else {
            assertionFailure("ChartRow should have a heading")
            return
        }

        // If the heading value changed, remove the entity and redraw it
        if let entity = heading.entity,
           entity.name != heading.value
        {
            chart.removeChild(entity)
            heading.entity = nil
        }

        // Create a new heading entity if needed
        let entity = heading.entity ?? {
            chartBoundsDidChange = true
            let mesh = MeshResource.generateText(heading.value,
                                                 extrusionDepth: 2)
            let colorMaterial = SimpleMaterial(color: .black,
                                               isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [colorMaterial])

            // Store the heading value in the name to compare later
            entity.name = heading.value

            // Size the text appropriately for the chart
            entity.scale *= 0.002

            chart.addChild(entity)

            // Rotate the text by 90 degrees to lay flat
            entity.orientation = simd_quatf(angle: -1 * .pi * 0.5,
                                            axis: [1, 0, 0])

            // Position the heading after the row
            let bounds = entity.visualBounds(relativeTo: nil).extents
            let cellSize = barSize + barPadding
            let rowMaxX = cellSize * Float(row.data.count - 1) - barPadding
            let rowZ = cellSize * Float(rowIndex)
            entity.transform.translation.y = basePlateHeight * 0.5
            entity.transform.translation.x = rowMaxX + basePlatePadding * 0.25
            entity.transform.translation.z = rowZ + barSize - bounds.y

            // Store the new entity in this ChartData
            heading.entity = entity

            return entity
        }()
    }

    private func drawBasePlate(inBounds bounds: SIMD3<Float>) {
        basePlate?.removeFromParent()

        // Add padding to the chart bounds
        let basePlateBounds = bounds + SIMD3<Float>(repeating: basePlatePadding)

        let mesh = MeshResource.generateBox(width: basePlateBounds.x,
                                            height: basePlateHeight,
                                            depth: basePlateBounds.z,
                                            cornerRadius: basePlateHeight * 0.5)
        let colorMaterial = SimpleMaterial(color: .white,
                                           roughness: 0.1,
                                           isMetallic: false)
        let basePlate = ModelEntity(mesh: mesh, materials: [colorMaterial])
        chart.addChild(basePlate)

        // Position the middle of the base plate in the middle of the chart
        basePlate.transform.translation.x += bounds.x * 0.5
        basePlate.transform.translation.z += bounds.z * 0.5

        self.basePlate = basePlate
    }
}
