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
    let stepSize: Double = 100.0
    
    @State private var chartData: [ChartData] = []
    @State private var yCount = 10
    @State private var dragIndex: Int?

    
    var body: some View {
        VStack {
            Chart {
                ForEach(chartData) { item in
                    LineMark(
                        x: .value("Time", item.date),
                        y: .value("Temp", item.temp)
                    )
                    .symbol {
                        Circle()
                            .fill(dragIndex == indexOf(item) ? .red : .blue.opacity(0.5))
                            .frame(width: 30)
                    }
                }
            }
            .padding(15)

            .chartGesture { proxy in
                DragGesture(minimumDistance: 1)
                    .onChanged {
                        if let (date, temp) = proxy.value(at: $0.location, as: (Date, Double).self) {
                            
                            if dragIndex == nil, let index = closestChartData(to: date, targetTemp: temp) {
                                chartData[index].date = date
                                chartData[index].temp = temp
                                dragIndex = index
                            } else {
                                chartData[dragIndex!].date = date
                                chartData[dragIndex!].temp = temp
                            }
                        }
                    }
                    .onEnded { _ in
                        dragIndex = nil
                    }
            }
            
            .chartPlotStyle {
                $0.background(.pink.opacity(0.06))
                    .border(.blue, width: 2)
            }
            
            .chartXAxis {
                AxisMarks(values: chartData.map { $0.date }) { value in
                    AxisGridLine()
                    AxisTick()
                    // AxisValueLabel(format: .dateTime.hour())
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(timeStringOf(date))
                        }
                    }
                }
            }
            
            .chartYAxis {
                AxisMarks(position: .leading,
                          values: .automatic(desiredCount: yCount)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let val = value.as(Int.self) {
                            Text("\(val) \u{00B0}")
                                .font(.system(size: 18))
                                .bold()
                        }
                    }
                }
            }
        }
        .background(Color.purple.opacity(0.1).ignoresSafeArea())
        .onAppear {
            chartData = getData()
            // adjust the number of Y axis labels from the data
            if let min = chartData.min(by: { $0.temp < $1.temp }),
               let max = chartData.max(by: { $0.temp < $1.temp }) {
                yCount = Int((max.temp - min.temp) / stepSize) + 1
            }
        }
    }
    
    func getData() -> [ChartData] {
        [
            ChartData(temp: 0.0, date: Date()),
            ChartData(temp: 100.0, date: Date().addingTimeInterval(3600)),
            ChartData(temp: 200.0, date: Date().addingTimeInterval(3600 * 2)),
            ChartData(temp: 300.0, date: Date().addingTimeInterval(3600 * 3)),
            ChartData(temp: 400.0, date: Date().addingTimeInterval(3600 * 4)),
            ChartData(temp: 500.0, date: Date().addingTimeInterval(3600 * 5)),
            ChartData(temp: 600.0, date: Date().addingTimeInterval(3600 * 6)),
            ChartData(temp: 700.0, date: Date().addingTimeInterval(3600 * 7)),
            ChartData(temp: 800.0, date: Date().addingTimeInterval(3600 * 8))
        ]
    }
    
    func closestChartData(to targetDate: Date, targetTemp: Double) -> Int? {
        guard !chartData.isEmpty else { return nil }
        
        var closestChartData: ChartData?
        var minDistance: Double = .infinity
        
        for datum in chartData {
            let timeInterval = abs(datum.date.timeIntervalSince(targetDate))
            let tempDifference = abs(datum.temp - targetTemp)
            
            // weighted (0.5 and 0.5) distance
            let distance = 0.5 * timeInterval + 0.5 * tempDifference
            
            if distance < minDistance {
                minDistance = distance
                closestChartData = datum
            }
        }
        if let closest = closestChartData {
            return chartData.firstIndex(where: {closest.id == $0.id})
        }
        return nil
    }
    
    func timeStringOf(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func indexOf(_ datum: ChartData) -> Int? {
        chartData.firstIndex(where: {datum.id == $0.id})
    }
    
}

struct ChartData: Identifiable {
    let id = UUID()
    
    var temp: Double
    var date: Date
}


#Preview {
    ContentView()
}
