import SwiftUI

// MARK: - Welcome Screen

struct WelcomeView: View {
    var onStart: () -> Void = {}

    @State private var flyAway = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // تصميم الأصل 390 × 844
            let sx = w / 390
            let sy = h / 844

            ZStack {
                Color.appBg.ignoresSafeArea()

                LightRays()
                    .ignoresSafeArea()

                // Clouds (تنجرف ببطء)
                CloudView().frame(width: 140, height: 70)
                    .position(x: 110 * sx, y: 230 * sy)
                    .drifting(distance: 12, duration: 7)
                CloudView().frame(width: 150, height: 70)
                    .position(x: 345 * sx, y: 280 * sy)
                    .drifting(distance: 14, duration: 9)
                CloudView().frame(width: 120, height: 60)
                    .position(x: 70 * sx, y: 430 * sy)
                    .drifting(distance: 10, duration: 8)
                CloudView().frame(width: 120, height: 60)
                    .position(x: 335 * sx, y: 440 * sy)
                    .drifting(distance: 12, duration: 6)

                // Welcome text
                Text("welcome")
                    .font(.custom("SnellRoundhand-Bold", size: 64))
                    .foregroundColor(.appGold)
                    .position(x: 195 * sx, y: 340 * sy)

                // Island (تطفو)
                WelcomeIslandView()
                    .frame(width: 330, height: 260)
                    .position(x: 195 * sx, y: 560 * sy)
                    .floating(amplitude: 5, duration: 2.4)

                // Eagle (نفس نسر الهوم) - يطير لفوق لما تضغط Start
                EagleView()
                    .scaleEffect(w * 0.70 / 370)
                    .frame(width: w * 0.70, height: w * 0.70 * 180 / 370)
                    .position(x: w * 0.5, y: h * 0.185)
                    .offset(y: flyAway ? -h * 0.5 : 0)
                    .allowsHitTesting(false)

                // Start button
                Button {
                    guard !flyAway else { return }
                    withAnimation(.easeIn(duration: 0.8)) { flyAway = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        onStart()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.appBrownDeep)
                            .offset(y: 6)
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.appBrown)
                        Text("Start")
                            .font(.system(size: 44, weight: .regular, design: .rounded))
                            .foregroundColor(.appGold)
                    }
                    .frame(width: 296, height: 68)
                }
                .buttonStyle(.plain)
                .position(x: 195 * sx, y: 740 * sy)
            }
            .frame(width: w, height: h)
        }
    }
}

// MARK: - Light rays

struct LightRays: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.10, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.42, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.75, y: h))
                    p.addLine(to: CGPoint(x: w * 0.45, y: h))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.10))

                Path { p in
                    p.move(to: CGPoint(x: w * 0.60, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.90, y: 0))
                    p.addLine(to: CGPoint(x: w * 1.10, y: h * 0.8))
                    p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.8))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.08))
            }
        }
    }
}

// MARK: - Cloud

struct CloudView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Ellipse()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: w, height: h * 0.55)
                    .position(x: w * 0.45, y: h * 0.72)
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: w * 0.42, height: w * 0.42)
                    .position(x: w * 0.50, y: h * 0.42)
                Ellipse()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: w * 0.36, height: h * 0.5)
                    .position(x: w * 0.78, y: h * 0.62)
            }
        }
    }
}

// MARK: - Island (نخلة + صندوق الهوم)

struct WelcomeIslandView: View {
    var body: some View {
        ZStack {
            // Water ring
            Ellipse()
                .fill(Color(hex: "6F9A9C"))
                .frame(width: 322, height: 122)
                .offset(y: 40)

            // Shallow sand halo
            Ellipse()
                .fill(Color(hex: "C2BA84").opacity(0.85))
                .frame(width: 312, height: 100)
                .offset(y: 64)

            // Island side
            Ellipse()
                .fill(Color(hex: "A89060"))
                .frame(width: 290, height: 112)
                .offset(y: 52)

            // Island top
            Ellipse()
                .fill(Color(hex: "F8E08E"))
                .frame(width: 290, height: 108)
                .offset(y: 34)

            // النخلة الموحدة (من الهوم)
            PalmTree()
                .frame(width: 110, height: 95)
                .scaleEffect(1.5)
                .offset(x: -50, y: -45)

            // نفس صندوق الهوم (مكبّر)
            TreasureChest()
                .frame(width: 44, height: 40)
                .scaleEffect(2.2)
                .offset(x: 62, y: 22)
        }
    }
}

#Preview {
    WelcomeView()
}
