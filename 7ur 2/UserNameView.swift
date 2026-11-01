import SwiftUI

// MARK: - Screen
struct UserNameView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @FocusState private var isFieldFocused: Bool
    var points: Int = 5
    var onConfirm: (String) -> Void = { _ in }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            UserNameStripes().ignoresSafeArea()

            UserNameCloud().frame(width: 150, height: 75)
                .position(x: 80, y: 190)
            UserNameCloud().frame(width: 170, height: 85)
                .position(x: UIScreen.main.bounds.width - 90, y: 150)

            UserNameIsland()
                .frame(width: 140, height: 90)
                .position(x: 70, y: 470)

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
        .ignoresSafeArea(.keyboard)
        .onTapGesture { isFieldFocused = false }
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
                Circle().fill(Color.appGold).frame(width: 40, height: 40)
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

private struct UserNameIsland: View {
    var body: some View {
        ZStack {
            Ellipse().fill(.white.opacity(0.35))
                .frame(width: 140, height: 40).offset(y: 22)
            Ellipse().fill(Color(hex: 0xC9AE6A))
                .frame(width: 110, height: 34).offset(y: 12)
            Ellipse().fill(Color.appGold)
                .frame(width: 24, height: 7).offset(y: 10)
            Capsule().fill(Color.appBrown)
                .frame(width: 5, height: 42)
                .rotationEffect(.degrees(-6)).offset(x: -4, y: -14)
            Capsule().fill(Color(hex: 0x3E7A52))
                .frame(width: 34, height: 8)
                .rotationEffect(.degrees(-20)).offset(x: -20, y: -36)
            Capsule().fill(Color(hex: 0x3E7A52))
                .frame(width: 34, height: 8)
                .rotationEffect(.degrees(20)).offset(x: 10, y: -36)
        }
    }
}

#Preview {
    UserNameView()
}
