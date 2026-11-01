import SwiftUI

// MARK: - Welcome Screen

struct WelcomeView: View {
    var onStart: () -> Void = {}
    
    // حالة لتتبع اسم المستخدم المسجل مسبقاً لتجاوزه وعدم طلبه مجدداً
    @AppStorage("user_display_name") private var storedName: String = ""

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // تصميم الأصل 390 × 844
            // توافق الأجهزة: نحافظ على نسبة التصميم الأصلي ونوسّطه داخل الشاشة
            // (ايفون / ايفون قابل للطي / ايباد بكل الاتجاهات)، والخلفية تملأ الشاشة كاملة
            let s = min(w / 390, h / 844)
            let ox = (w - 390 * s) / 2
            let oy = (h - 844 * s) / 2
            let px: (CGFloat) -> CGFloat = { ox + s * $0 }
            let py: (CGFloat) -> CGFloat = { oy + s * $0 }

            ZStack {
                Color.appBg.ignoresSafeArea()

                LightRays()
                    .ignoresSafeArea()

                // Clouds (تنجرف ببطء)
                CloudView().frame(width: 140 * s, height: 70 * s)
                    .position(x: px(110), y: py(190))
                    .drifting(distance: 12, duration: 7)
                CloudView().frame(width: 150 * s, height: 70 * s)
                    .position(x: px(345), y: py(260))
                    .drifting(distance: 14, duration: 9)
                CloudView().frame(width: 120 * s, height: 60 * s)
                    .position(x: px(80), y: py(480))
                    .drifting(distance: 10, duration: 8)
                CloudView().frame(width: 120 * s, height: 60 * s)
                    .position(x: px(330), y: py(540))
                    .drifting(distance: 12, duration: 6)

                // EagleView (النسر الموحد)
                EagleView()
                    .scaleEffect(160 * s / 370)
                    .frame(width: 160 * s, height: 160 * s * 180 / 370)
                    .position(x: px(195), y: py(90))

                // Welcome text
                Text("welcome")
                    .font(.custom("SnellRoundhand-Bold", size: 64 * s))
                    .foregroundColor(.appGold)
                    .position(x: px(195), y: py(340))

                // Island (تطفو)
                WelcomeIslandView()
                    .frame(width: 330, height: 260)
                    .scaleEffect(s)
                    .frame(width: 330 * s, height: 260 * s)
                    .position(x: px(195), y: py(560))
                    .floating(amplitude: 5, duration: 2.4)

                // Start button (الانتقال المباشر وتجاوز إدخال الاسم لوجوده مسبقاً)
                Button(action: {
                    onStart()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28 * s)
                            .fill(Color.appBrownDeep)
                            .offset(y: 6 * s)
                        RoundedRectangle(cornerRadius: 28 * s)
                            .fill(Color.appBrown)
                        Text("Start")
                            .font(.system(size: 44 * s, weight: .regular, design: .rounded))
                            .foregroundColor(.appGold)
                    }
                    .frame(width: 296 * s, height: 68 * s)
                }
                .buttonStyle(.plain)
                .position(x: px(195), y: py(740))
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

// MARK: - Island

struct WelcomeIslandView: View {
    var body: some View {
        ZStack {
            // Water ring
            Ellipse()
                .fill(Color(hex: 0x6F9A9C))
                .frame(width: 322, height: 122)
                .offset(y: 40)

            // Shallow sand halo
            Ellipse()
                .fill(Color(hex: 0xC2BA84).opacity(0.85))
                .frame(width: 312, height: 100)
                .offset(y: 64)

            // Island side
            Ellipse()
                .fill(Color(hex: 0xA89060))
                .frame(width: 290, height: 112)
                .offset(y: 52)

            // Island top
            Ellipse()
                .fill(Color(hex: 0xF8E08E))
                .frame(width: 290, height: 108)
                .offset(y: 34)

            // النخلة الموحدة
            PalmTree()
                .frame(width: 110, height: 95)
                .scaleEffect(1.5)
                .offset(x: -50, y: -45)

            // TreasureChest (المشترك من الهوم) مع الكوينز على الأرض
            ZStack {
                TreasureChest()
                
                // العملات المعدنية على الأرض بجانب الصندوق
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(Color(hex: 0xF5C14B))
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color(hex: 0xD69B2D), lineWidth: 1))
                    }
                }
                .offset(x: 18, y: 18)
            }
            .scaleEffect(1.35)
            .offset(x: 55, y: 10)
        }
    }
}

#Preview {
    WelcomeView()
}
