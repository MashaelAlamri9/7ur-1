import SwiftUI

// MARK: - Screen
struct UserNameView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @FocusState private var isFieldFocused: Bool
    @State private var eagleIn = false
    var points: Int = 5
    var onConfirm: (String) -> Void = { _ in }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Color.appBg.ignoresSafeArea()
                UserNameStripes().ignoresSafeArea()

                // سحب
                UserNameCloud().frame(width: 130, height: 65)
                    .position(x: 70, y: h * 0.50)
                    .drifting(distance: 12, duration: 7)
                UserNameCloud().frame(width: 150, height: 75)
                    .position(x: w - 70, y: h * 0.47)
                    .drifting(distance: 14, duration: 9)

                // الجزيرة بالنص تحت مع الكنز
                WelcomeIslandView()
                    .frame(width: 330, height: 260)
                    .scaleEffect(0.85)
                    .position(x: w / 2, y: h * 0.80)
                    .floating(amplitude: 4, duration: 2.3)

                // النورس (يدخل من فوق ويقعد لين يكتب الاسم)
                EagleView()
                    .scaleEffect(w * 0.55 / 370)
                    .frame(width: w * 0.55, height: w * 0.55 * 180 / 370)
                    .position(x: w / 2, y: 135)
                    .offset(y: eagleIn ? 0 : -h * 0.5)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    HStack {
                        UserNamePointsPill(points: points)
                        Spacer()
                        Button {
                            isFieldFocused = false
                            onConfirm(userName)
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

                    Spacer().frame(height: 130)

                    Text("your name")
                        .font(.custom("SnellRoundhand-Bold", size: 52))
                        .foregroundStyle(Color.appGold)

                    Spacer().frame(height: 30)

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
                                isFieldFocused = false
                                onConfirm(userName)
                            }
                            .padding(.horizontal, 24)
                    }
                    .frame(height: 66)
                    .padding(.horizontal, 24)
                    .contentShape(Rectangle())
                    .onTapGesture { isFieldFocused = true }

                    Spacer().frame(height: 22)

                    Text("friends will see this name on the board")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(hex: 0x6F8F8A))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.appCream))

                    Spacer()
                }
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture { isFieldFocused = false }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) { eagleIn = true }
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
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.appGold)
                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: 0x6B4A1A))
                }
                .frame(width: 40, height: 40)
                Text("\(points) points")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appGold)
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 160, height: 52)
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

#Preview {
    UserNameView()
}
