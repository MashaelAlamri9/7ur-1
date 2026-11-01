import SwiftUI
import UIKit

// MARK: - Screen
struct UserNameView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @FocusState private var isFieldFocused: Bool
    var points: Int = 5
    var onConfirm: (String) -> Void = { _ in }

    // متغير حالة للتحكم بالانتقال إلى صفحة الهوم (الجزر) مباشرة
    @State private var navigateToHome: Bool = false

    // المسافة الحقيقية من أعلى الشاشة (Dynamic Island / النوتش / شريط الحالة)
    // نقرأها من النافذة مباشرة لأن geo.safeAreaInsets داخل NavigationStack مع ignoresSafeArea
    // ممكن يرجع قيمة غلط (0 أو يشمل شريط التنقل) فتطلع الأزرار فوق أو تحت مكانها
    private var windowTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
    }

    
    var body: some View {
        NavigationStack {
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
                    UserNameStripes().ignoresSafeArea()

                    UserNameCloud().frame(width: 150 * s, height: 75 * s)
                        .position(x: px(80), y: py(190))
                        .drifting(distance: 12, duration: 7)
                    UserNameCloud().frame(width: 170 * s, height: 85 * s)
                        .position(x: px(390 - 90), y: py(150))
                        .drifting(distance: 14, duration: 9)

                    UserNameIsland()
                        .frame(width: 140, height: 90)
                        .scaleEffect(s)
                        .frame(width: 140 * s, height: 90 * s)
                        .position(x: px(70), y: py(470))
                        .floating(amplitude: 4, duration: 2.3)

                    VStack(spacing: 0) {
                        HStack {
                            UserNamePointsPill(points: points)
                            Spacer()
                            Button {
                                AudioManager.shared.playSound("button_tap")
                                isFieldFocused = false
                                onConfirm(userName)
                                UserDefaults.standard.set(userName, forKey: "userName")
                                navigateToHome = true
                            } label: {
                                ZStack {
                                    Circle().fill(Color.appBrownEdge).offset(y: 4)
                                    Circle().fill(Color.appBrown)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color.appGold)
                                }
                                .frame(width: 56, height: 56)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        Spacer().frame(height: 120)

                        Text("your name")
                            .font(.custom("SnellRoundhand-Bold", size: 52))
                            .foregroundStyle(Color.appGold)

                        Spacer().frame(height: 40)

                        ZStack {
                            Capsule().fill(Color.appBrownEdge).offset(y: 5)
                            Capsule().fill(Color.appBrown)

                            TextField("", text: $userName,
                                    prompt: Text("User Name")
                                        .foregroundColor(.white.opacity(0.85)))
                                .focused($isFieldFocused)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .submitLabel(.done)
                                .onSubmit {
                                    AudioManager.shared.playSound("button_tap")
                                    isFieldFocused = false
                                    onConfirm(userName)
                                    UserDefaults.standard.set(userName, forKey: "userName")
                                    navigateToHome = true
                                }
                                .padding(.horizontal, 24)
                        }
                        .frame(height: 66)
                        .padding(.horizontal, 24)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            AudioManager.shared.playSound("button_tap")
                            isFieldFocused = true
                        }

                        Spacer().frame(height: 22)

                        Text("friends will see this name on the board")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(hex: 0x6F8F8A))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.appCream))

                        Spacer()
                    }
                    // المحتوى الأساسي يتصمم على لوحة 390 × 844 ثم يتكبر/يتصغر حسب الجهاز
                    .padding(.top, topInset)
                    .frame(width: 390, height: 844)
                    .scaleEffect(s)
                    .position(x: w / 2, y: h / 2)
                }
                .frame(width: w, height: h)
                .ignoresSafeArea(.keyboard)
                .onTapGesture { isFieldFocused = false }
                .navigationDestination(isPresented: $navigateToHome) {
                    IslandsMapView() // الانتقال المباشر لواجهة الجزر الرئيسية
                }
            }
            .ignoresSafeArea()
            // شريط التنقل فاضي وما نحتاجه، نخفيه عشان ما يتداخل مع مكان الأزرار العلوية
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Components
private struct UserNamePointsPill: View {
    let points: Int
    var body: some View {
        ZStack {
            Capsule().fill(Color.appBrownEdge).offset(y: 4)
            Capsule().fill(Color.appBrown)
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.appGold)
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: 0x6B4A1A))
                }
                .frame(width: 26, height: 26)
                Text("\(points)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appGold)
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 140, height: 52)
    }
}

private struct UserNameStripes: View {
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

private struct UserNameCloud: View {
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
    }
}

private struct UserNameIsland: View {
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
    UserNameView()
}
