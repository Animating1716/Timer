import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
    }
}

struct MiniProgressRing: View {
    let progress: Double
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    lineWidth: 2
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress >= 1.0 ? Color.green : Color.blue.opacity(0.7),
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
        .padding(isSelected ? 0 : 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    VStack(spacing: 40) {
        TimerRingView(progress: 0.7, color: .blue, lineWidth: 8)
            .frame(width: 250, height: 250)

        HStack(spacing: 12) {
            MiniProgressRing(progress: 0.5, isSelected: false)
                .frame(width: 44, height: 44)
            MiniProgressRing(progress: 1.0, isSelected: true)
                .frame(width: 44, height: 44)
            MiniProgressRing(progress: 0.0, isSelected: false)
                .frame(width: 44, height: 44)
        }
    }
    .padding()
    .background(Color.black)
}
