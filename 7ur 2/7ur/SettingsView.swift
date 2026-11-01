import SwiftUI
import UIKit

// MARK: - Screen
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var onBack: (() -> Void)? = nil

    @AppStorage("musicVolume") private var musicVolume: Double = 0.7
    @AppStorage("musicAllowed") private var musicAllowed = true
    @AppStorage("sfxVolume") private var sfxVolume: Double = 0.55
    @AppStorage("sfxAllowed") private var sfxAllowed = true

    // المسافة الحقيقية من أعلى الشاشة (Dynamic Island / النوتش / شريط الحالة)
    // نقرأها من النافذة مباشرة عشان زر الرجوع ما يطلع تحت الـ Dynamic Island أو بعيد عن مكانه
    private var windowTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
    }

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
            // نحافظ على المسافة من الـ Safe Area (النوتش / Dynamic Island) فقط لو المحتوى يلمسها
            let topInset = max(0, windowTopInset - oy) / s

            ZStack {
                Color.appBg.ignoresSafeArea()
                SettingsStripes().ignoresSafeArea()

                SettingsCloud().frame(width: 140 * s, height: 70 * s)
                    .position(x: px(90), y: py(150))
                    .drifting(distance: 12, duration: 7)
                SettingsCloud().frame(width: 150 * s, height: 75 * s)
                    .position(x: px(390 - 70), y: py(215))
                    .drifting(distance: 14, duration: 9)

                SettingsIsland()
                    .frame(width: 140, height: 90)
                    .scaleEffect(s)
                    .frame(width: 140 * s, height: 90 * s)
                    .position(x: px(75), y: py(844 - 150))
                    .floating(amplitude: 4, duration: 2.3)

                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 6) {
                            Text("Setting")
                                .font(.custom("SnellRoundhand-Bold", size: 64))
                                .foregroundStyle(Color.appGold)
                            Text("make your island yours")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)

                        AppCircleButton(systemName: "chevron.left", size: 48) {
                            AudioManager.shared.playSound("button_tap")

                            if let onBack {
                                onBack()
                            } else {
                                dismiss()
                            }
                        }
                        .padding(.leading, 20)
                    }
                    .padding(.top, 12)

                    Spacer().frame(height: 36)

                    VStack(spacing: 28) {
                        SettingsCard(title: "music",
                                     volume: $musicVolume,
                                     allowed: $musicAllowed)
                        SettingsCard(title: "sound effect",
                                     volume: $sfxVolume,
                                     allowed: $sfxAllowed)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                // المحتوى الأساسي يتصمم على لوحة 390 × 844 ثم يتكبر/يتصغر حسب الجهاز
                .padding(.top, topInset)
                .frame(width: 390, height: 844)
                .scaleEffect(s)
                .position(x: w / 2, y: h / 2)
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
       
        .navigationBarBackButtonHidden(true)
        .onAppear {
            AudioManager.shared.playSound("page_open")
        }
        .onChange(of: musicVolume) { _, _ in
            AudioManager.shared.updateMusicSettings()
        }
        .onChange(of: musicAllowed) { _, _ in
            AudioManager.shared.updateMusicSettings()
        }
        .onChange(of: sfxVolume) { _, _ in
            AudioManager.shared.updateSoundSettings()
        }
        .onChange(of: sfxAllowed) { _, _ in
            AudioManager.shared.updateSoundSettings()
        }

    }
}

// MARK: - Card
private struct SettingsCard: View {
    let title: String
    @Binding var volume: Double
    @Binding var allowed: Bool

    private let text = Color(hex: 0xE9DFC9)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(text)

            SettingsSlider(value: $volume)
                .frame(height: 28)
                .opacity(allowed ? 1 : 0.4)
                .disabled(!allowed)

            Rectangle()
                .fill(text.opacity(0.15))
                .frame(height: 1)

            HStack {
                Text("allow")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(text)
                Spacer()
                SettingsToggle(isOn: $allowed)

            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30).fill(Color.appBrownDeep).offset(y: 6)
                RoundedRectangle(cornerRadius: 30).fill(Color.appBrown)
            }
        )
    }
}

// MARK: - Custom slider
private struct SettingsSlider: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geo in
            let knob: CGFloat = 28
            let width = geo.size.width - knob
            ZStack(alignment: .leading) {
                Capsule().fill(Color.appBrownDeep).frame(height: 14)
                Capsule().fill(Color.appGoldSoft)
                    .frame(width: CGFloat(value) * width + knob / 2, height: 14)
                Circle().fill(Color.appGold)
                    .overlay(Circle().stroke(Color.appGoldSoft, lineWidth: 3))
                    .frame(width: knob, height: knob)
                    .offset(x: CGFloat(value) * width)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let v = (g.location.x - knob / 2) / width
                        value = min(max(Double(v), 0), 1)
                    }
            )
        }
    }
}

// MARK: - Custom toggle

private struct SettingsToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                isOn.toggle()
            }

            AudioManager.shared.playSound("toggle")
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? Color.appGold : Color.appBrownDeep)
                    .frame(width: 76, height: 42)

                Circle()
                    .fill(Color(hex: 0xEDE6D6))
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 5)
            }
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Decorations
private struct SettingsStripes: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { i in
                    Rectangle()
                        .fill(i % 2 == 0 ? Color.clear : Color.appStripe.opacity(0.7))
                }
            }
            .frame(width: geo.size.width * 1.4, height: geo.size.height * 1.3)
            .rotationEffect(.degrees(8))
            .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
        }
        .clipped()
    }
}

private struct SettingsCloud: View {
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                Circle().fill(.white).frame(width: h * 0.85)
                    .position(x: w * 0.40, y: h * 0.40)
                Circle().fill(.white).frame(width: h * 0.55)
                    .position(x: w * 0.65, y: h * 0.58)
                Capsule().fill(.white).frame(width: w, height: h * 0.45)
                    .position(x: w * 0.5, y: h * 0.78)
            }
        }
        .opacity(0.9)
    }
}

private struct SettingsIsland: View {
    var body: some View {
        ZStack {
            Ellipse().fill(.white.opacity(0.35))
                .frame(width: 140, height: 40).offset(y: 22)
            Ellipse().fill(Color(hex: 0xC9AE6A))
                .frame(width: 110, height: 34).offset(y: 12)
            Ellipse().fill(Color.appGold)
                .frame(width: 24, height: 7).offset(y: 10)
            PalmTree()
                .frame(width: 110, height: 95)
                .scaleEffect(0.6)
                .offset(x: -5, y: -17)
        }
    }
}

#Preview {
    SettingsView()
}
