//
//  ContentView.swift
//  InteractiveChart
//
//  Created by Ringo Wathelet on 2024/09/29.
//

import Foundation
import SwiftUI
import Charts


struct ContentView: View {
    let dy = 15.0
    let dx = 15.0
    
    @State private var chartData: [ChartData] = []
    @State private var dragData: ChartData?
    
    
    var body: some View {
        VStack {
            Chart {
                ForEach(chartData) { point in
                    LineMark(x: .value("X", point.x), y: .value("Y", point.y))
                    // PointMark(x: .value("X", point.x), y: .value("Y", point.y))
                        .symbol {
                            Circle()
                                .fill(dragData?.id == point.id ? .red : .blue.opacity(0.5))
                                .frame(width: dx+dy)
                        }
                        .interpolationMethod(.catmullRom)
                }
            }
            .padding(15)
            
            .chartGesture { proxy in
                DragGesture(minimumDistance: 0)
                    .onChanged {
                        if let target: (x: Double, y: Double) = proxy.value(at: $0.location, as: (Double, Double).self) {
                            if dragData == nil, let chartData = closestChartData(to: target) {
                                dragData = chartData
                            } else {
                                dragData?.x = target.x
                                dragData?.y = target.y
                            }
                        }
                    }
                    .onEnded { _ in
                        dragData = nil
                    }
            }
            
            .chartPlotStyle {
                $0.background(.pink.opacity(0.06))
                    .border(.blue, width: 2)
            }
        }
        .onAppear {
            chartData = [
                ChartData(x: 0.0, y: 0.0),
                ChartData(x: 100.0, y: 100.0),
                ChartData(x: 200.0, y: 200.0),
                ChartData(x: 300.0, y: 300.0),
                ChartData(x: 400.0, y: 400.0),
                ChartData(x: 500.0, y: 500.0),
                ChartData(x: 600.0, y: 600.0),
                ChartData(x: 700.0, y: 700.0),
                ChartData(x: 800.0, y: 800.0)
            ]
        }
    }
    
    func closestChartData(to target: (x: Double, y: Double)) -> ChartData? {
        var closestChartData: ChartData?
        for datum in chartData {
            let xdiff = abs(datum.x - target.x)
            let ydiff = abs(datum.y - target.y)
            if xdiff < dx && ydiff < dy {
                closestChartData = datum
            }
        }
        return closestChartData
    }
}

@Observable class ChartData: Identifiable {
    let id = UUID()
    
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
