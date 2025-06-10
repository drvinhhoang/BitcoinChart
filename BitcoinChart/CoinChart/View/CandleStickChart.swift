import SwiftUI
import Charts

struct CandleStickChart: View {
    var candleSticks: [CandleStick]
    var candleWidth: Double
    var bound: ClosedRange<Double>
    let chartData: ChartData?
    let isLoading: Bool

    @State private var scale: CGFloat = 1.0
    @State private var selectedPrice: Double?
    @State private var dragLocation: CGPoint = .zero

    init(chartData: ChartData?, isLoading: Bool) {
        self.chartData = chartData
        self.candleSticks = chartData?.items ?? []
        self.candleWidth = chartData?.intervalRange.candleWidth ?? 0
        self.bound = chartData?.bounds ?? 0...100
        self.isLoading = isLoading
    }

    var body: some View {
        VStack {
            ZStack {
                scrollableChart
                if let price = selectedPrice {
                    Text(price.asNumberWith2Decimals())
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .offset(x: dragLocation.x, y: 0)
                }
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
        }
    }

    private func updatePrice(location: CGPoint, size: CGSize) {
        let y = min(max(0, location.y), size.height)
        let percent = 1 - (y / size.height)
        let price = bound.lowerBound + percent * (bound.upperBound - bound.lowerBound)
        selectedPrice = price
        dragLocation = location
    }

    private var scrollableChart: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                chart
                    .frame(width: (chartData?.intervalRange.chartWidth ?? proxy.size.width) * scale,
                           height: proxy.size.height)
                    .gesture(MagnificationGesture().onChanged { value in
                        scale = max(1, value)
                    })
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updatePrice(location: value.location, size: proxy.size)
                                }
                                .onEnded { _ in selectedPrice = nil })
            }
        }
    }

    private var chart: some View {
        Chart(candleSticks) { candle in
            CandleStickMark(
                timestamp: .value("Date", candle.timestamp),
                open: .value("Open", candle.open),
                high: .value("High", candle.high),
                low: .value("Low", candle.low),
                close: .value("Close", candle.close),
                width: candleWidth
            )
            .foregroundStyle(candle.isClosingHigher ? .green : .red)
        }
        .chartYAxis { AxisMarks(preset: .automatic, values: .automatic()) }
        .chartXAxis { AxisMarks(preset: .automatic, values: .automatic()) }
        .chartYScale(domain: bound)
    }
}
