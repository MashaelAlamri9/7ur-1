import SwiftUI

// MARK: - Color helpers + app palette (الملف الوحيد الذي يعرّف Color(hex:))
extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }

    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: s).scanHexInt64(&int)
        self.init(hex: UInt32(int))
    }

    // ===== الألوان الموحدة للتطبيق =====
    static let appBg        = Color(hex: 0x86A5A6)  // خلفية البحر
    static let appStripe    = Color(hex: 0x9DB5A8)  // خطوط الخلفية
    static let appBrown     = Color(hex: 0x6B4A35)  // الأزرار والكبسولات
    static let appBrownEdge = Color(hex: 0x9A7658)  // حدود الأزرار
    static let appBrownDeep = Color(hex: 0x4A3324)  // ظل الأزرار / النصوص الغامقة
    static let appGold      = Color(hex: 0xF2C94C)  // العناوين والنقاط
    static let appGoldSoft  = Color(hex: 0xF3DC8B)
    static let appCream     = Color(hex: 0xF1E9DC)  // البطاقات والتلميحات
}

// MARK: - Motion (حركات خفيفة موحدة لكل الصفحات)

/// طفو خفيف (فوق/تحت) مثل الجزر في الهوم
struct FloatEffect: ViewModifier {
    let amplitude: CGFloat
    let duration: Double
    let delay: Double
    @State private var up = false

    func body(content: Content) -> some View {
        content
            .offset(y: up ? -amplitude : amplitude)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay),
                       value: up)
            .onAppear { up = true }
    }
}

/// انجراف أفقي بطيء (للغيوم)
struct DriftEffect: ViewModifier {
    let distance: CGFloat
    let duration: Double
    @State private var moved = false

    func body(content: Content) -> some View {
        content
            .offset(x: moved ? distance : -distance)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true),
                       value: moved)
            .onAppear { moved = true }
    }
}

extension View {
    func floating(amplitude: CGFloat = 4, duration: Double = 2.2, delay: Double = 0) -> some View {
        modifier(FloatEffect(amplitude: amplitude, duration: duration, delay: delay))
    }

    func drifting(distance: CGFloat = 12, duration: Double = 7) -> some View {
        modifier(DriftEffect(distance: distance, duration: duration))
    }
}

// MARK: - Shared round button (نفس شكل أزرار الهوم في كل الصفحات)

struct AppCircleButton: View {
    let systemName: String
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.appGold)
                .frame(width: size, height: size)
                .background(Color.appBrown)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appBrownEdge, lineWidth: 3))
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }
}
