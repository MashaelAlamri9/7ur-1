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
