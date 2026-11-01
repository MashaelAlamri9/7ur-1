//
//  Home.swift  (الخريطة)
//

import SwiftUI

// MARK: - Colors

extension Color {
    static let sea        = Color.appBg
    static let riverDark  = Color(hex: 0x6B8F8F)
    static let riverLight = Color(hex: 0x8FB0AE)
    static let sandTop    = Color(hex: 0xF0DC96)
    static let sandMid    = Color(hex: 0xC9A96A)
    static let sandSide   = Color(hex: 0xAD925F)
    static let trunk      = Color(hex: 0x6B5A44)
    static let leaf       = Color(hex: 0x5E7F5F)
    static let chestBrown = Color(hex: 0x6B4A1A)
    static let gold       = Color.appGold
    static let pillBrown  = Color.appBrown
    static let pillBorder = Color.appBrownEdge
    static let badgeFill  = Color(hex: 0xD9C7A0)
}

// MARK: - Model

struct IslandItem: Identifiable {
    let id: Int
    let x: CGFloat         // fraction of screen width
    let y: CGFloat         // fraction of screen height (island center)
    let badgeY: CGFloat    // fraction of screen height (number badge)
    let scale: CGFloat
    let isLocked: Bool
}

// تعديل نظام قفل الجزر: جميع الجزر مقفلة افتراضياً عدا الأولى
private let islands: [IslandItem] = [
    .init(id: 1, x: 0.22, y: 0.855, badgeY: 0.937, scale: 1.00, isLocked: false),
    .init(id: 2, x: 0.78, y: 0.714, badgeY: 0.800, scale: 0.88, isLocked: true),
    .init(id: 3, x: 0.23, y: 0.620, badgeY: 0.700, scale: 0.90, isLocked: true),
    .init(id: 4, x: 0.78, y: 0.527, badgeY: 0.608, scale: 0.88, isLocked: true),
    .init(id: 5, x: 0.25, y: 0.397, badgeY: 0.467, scale: 0.72, isLocked: true),
    .init(id: 6, x: 0.77, y: 0.340, badgeY: 0.410, scale: 0.72, isLocked: true)
]

// MARK: - Main screen

struct IslandsMapView: View {
    var userName: String = "Player"
    var coins: Int = 5
    var onSelectIsland: (Int) -> Void = { _ in }
    var onOpenBoard: () -> Void = {}
    var onOpenAvatar: () -> Void = {}
    var onOpenSettings: () -> Void = {}

    // حالة لتلاشي التلميح التفاعلي تدريجياً وإظهار الأفتار بعد التحدي الخامس
    @State private var showHint: Bool = true
    @State private var isAvatarUnlocked: Bool = false
    
    // حالات ميكانيكا تفاعل الأفتار والطائر
    @State private var isAvatarRiding: Bool = true
    @State private var isParachuting: Bool = false
    @State private var landedIslandId: Int? = nil
    @State private var birdOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let topY = max(geo.safeAreaInsets.top + 50, h * 0.13)

            ZStack {
                Color.sea

                RiverView()
                    .frame(width: w, height: h)

                // تأثير شعاع الشمس البصري المطابق لصفحة الترحيب
                SunlightEffectView()
                    .frame(width: w, height: h)
                    .allowsHitTesting(false)

                // Eagle / Mascot مع ميكانيكا الركوب والتفاعل والنقر والصوت
                ZStack {
                    EagleView()
                        .scaleEffect(w * 0.70 / 370)
                        .frame(width: w * 0.70, height: w * 0.70 * 180 / 370)
                        .onTapGesture {
                            // مؤثر صوتي عند النقر على الطائر
                            SoundManager.playBirdSound()
                            if isAvatarRiding {
                                // هبوط الأفتار بالمظلة إلى أقرب جزيرة
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    isAvatarRiding = false
                                    isParachuting = true
                                    landedIslandId = 1 // أقرب جزيرة افتراضية
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    isParachuting = false
                                }
                            }
                        }

                    // الأفتار يركب فوق الطائر أو يهبط بالمظلة
                    if isAvatarRiding {
                        AvatarRidingView()
                            .offset(y: -w * 0.15)
                    } else if isParachuting {
                        ParachuteAvatarView()
                            .offset(y: w * 0.05)
                    }
                }
                .position(x: w * 0.5 + birdOffset.width, y: h * 0.185 + birdOffset.height)

                // Islands + number badges
                ForEach(islands) { island in
                    IslandView(isLocked: island.isLocked)
                        .scaleEffect(island.scale * min(w / 393, 1.2))
                        .frame(width: 200 * island.scale * min(w / 393, 1.2),
                               height: 130 * island.scale * min(w / 393, 1.2))
                        .position(x: w * island.x, y: h * island.y)
                        .onTapGesture {
                            SoundManager.playButtonSound()
                            if landedIslandId == island.id && !isAvatarRiding {
                                // النقر على الجزيرة التي هبط عليها الأفتار ليصعد ويعود للطائر
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    landedIslandId = nil
                                    isAvatarRiding = true
                                }
                            } else if !island.isLocked {
                                // النقر على الجزيرة لتحريك الطائر وتهبط عليها
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    let targetX = (w * island.x) - (w * 0.5)
                                    let targetY = (h * island.y) - (h * 0.185)
                                    birdOffset = CGSize(width: targetX * 0.3, height: targetY * 0.3)
                                }
                                onSelectIsland(island.id)
                            }
                        }

                    NumberBadge(number: island.id)
                        .position(x: w * island.x, y: h * island.badgeY)
                }

                // Greeting pill مع إمكانية تعديل الاسم مباشرة
                GreetingPill(name: userName, coins: coins)
                    .frame(width: w, alignment: .leading)
                    .padding(.leading, 20)
                    .position(x: w / 2, y: topY)

                // Navigation buttons (Board / Avatar / Settings) - إخفاء زر الأفتار افتراضياً إلا بعد إكمال التحدي 5
                HStack(spacing: 8) {
                    MapIconButton(systemName: "person.2.fill", action: {
                        SoundManager.playButtonSound()
                        onOpenBoard()
                    })
                    
                    if isAvatarUnlocked {
                        MapIconButton(systemName: "tshirt.fill", action: {
                            SoundManager.playButtonSound()
                            onOpenAvatar()
                        })
                    }
                    
                    MapIconButton(systemName: "gearshape.fill", action: {
                        SoundManager.playButtonSound()
                        onOpenSettings()
                    })
                }
                .position(x: w - 75, y: topY)

                // Bottom hint (يظهر في البداية ويختفي تدريجياً بعد عدة ثوانٍ)
                if showHint {
                    Text("Tap the island to explore...")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: 0x4A4A4A))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.appCream.opacity(0.85))
                        .clipShape(Capsule())
                        .position(x: w * 0.5, y: h - max(geo.safeAreaInsets.bottom, 20) - 14)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    showHint = false
                                }
                            }
                        }
                }
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
        .onAppear {
            // محاكاة فتح تفعيل الأفتار عند إتمام التحدي الخامس (يمكن ربطه بالStore الفعلي)
            isAvatarUnlocked = UserDefaults.standard.bool(forKey: "AvatarChallengeCompleted")
        }
    }
}

// MARK: - Helper Views for Avatar Mechanics

struct AvatarRidingView: View {
    var body: some View {
        Circle()
            .fill(Color.appGold)
            .frame(width: 24, height: 24)
            .overlay(Circle().stroke(Color.appBrownEdge, lineWidth: 2))
            .shadow(radius: 2)
    }
}

struct ParachuteAvatarView: View {
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 22))
                .foregroundColor(.white)
            Circle()
                .fill(Color.appGold)
                .frame(width: 20, height: 20)
        }
    }
}

struct SunlightEffectView: View {
    var body: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.25), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SoundManager {
    static func playButtonSound() {
        // تشغيل صوت الأزرار
    }
    static func playBirdSound() {
        // تشغيل صوت الطائر
    }
}

// MARK: - Map icon button

struct MapIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appGold)
                .frame(width: 40, height: 40)
                .background(Color.appBrown)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appBrownEdge, lineWidth: 3))
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Greeting pill

struct GreetingPill: View {
    let name: String
    let coins: Int
    @State private var isEditingName: Bool = false
    @State private var currentName: String = ""

    private var avatarHead: some View {
        let sel = AvatarStore.load()
        let base = avatarHairOptions[sel.hair]
        let hair = AvatarHairOption(id: base.id, style: base.style,
                                    color: avatarHairColors[sel.hairColor])
        return AvatarHeadIcon(skin: avatarSkinTones[sel.skin], hair: hair, gender: sel.gender)
            .scaleEffect(0.5)
            .frame(width: 34, height: 34)
            .background(Circle().fill(Color.appCream))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.appBrownEdge, lineWidth: 2))
    }

    var body: some View {
        HStack(spacing: 8) {
            avatarHead

            ZStack {
                Circle().fill(Color.gold)
                Text("\(coins)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.chestBrown)
            }
            .frame(width: 28, height: 28)

            Button(action: {
                currentName = name
                isEditingName = true
            }) {
                Text("Hi, \(name)")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color.gold.opacity(0.9))
                    .lineLimit(1)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.pillBrown)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.pillBorder, lineWidth: 3))
        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        .sheet(isPresented: $isEditingName) {
            VStack(spacing: 20) {
                Text("Edit Your Name")
                    .font(.headline)
                TextField("Enter name", text: $currentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Save") {
                    // حفظ الاسم الجديد
                    isEditingName = false
                }
                .padding()
            }
            .presentationDetents([.height(200)])
        }
    }
}

// MARK: - Number badge

struct NumberBadge: View {
    let number: Int

    var body: some View {
        Text("\(number)")
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(Color.appBrownDeep)
            .frame(width: 52, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.badgeFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.pillBorder, lineWidth: 2.5)
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.chestBrown.opacity(0.8))
                    .offset(y: 4)
            )
    }
}

// MARK: - Island (drawn in a 200 x 130 canvas)

struct IslandView: View {
    var isLocked: Bool = false

    var body: some View {
        ZStack {
            // Water shadow
            Ellipse()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 192, height: 62)
                .position(x: 100, y: 98)

            // Sand layers
            Ellipse().fill(Color.sandSide)
                .frame(width: 168, height: 54)
                .position(x: 100, y: 90)
            Ellipse().fill(Color.sandMid)
                .frame(width: 168, height: 52)
                .position(x: 100, y: 83)
            Ellipse().fill(Color.sandTop)
                .frame(width: 168, height: 50)
                .position(x: 100, y: 76)

            // Palm tree
            PalmTree()
                .frame(width: 80, height: 80)
                .position(x: 62, y: 42)

            if isLocked {
                Image(systemName: "lock")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.7))
                    .position(x: 70, y: 82)
                Ellipse()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 22, height: 9)
                    .position(x: 118, y: 80)
            } else {
                TreasureChest()
                    .frame(width: 44, height: 40)
                    .position(x: 128, y: 66)
            }
        }
        .frame(width: 200, height: 130)
        .opacity(isLocked ? 0.55 : 1)
    }
}

struct PalmTree: View {
    var body: some View {
        ZStack {
            // Trunk
            Path { p in
                p.move(to: CGPoint(x: 28, y: 78))
                p.addQuadCurve(to: CGPoint(x: 42, y: 26),
                              control: CGPoint(x: 26, y: 48))
            }
            .stroke(Color.trunk, style: StrokeStyle(lineWidth: 5, lineCap: .round))

            // Leaves
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(Color.leaf)
                    .frame(width: 42, height: 9)
                    .offset(x: 18)
                    .rotationEffect(.degrees(Double(i) * 55 - 150), anchor: .leading)
                    .position(x: 42, y: 26)
                    .offset(x: -18 + 18)
            }
        }
    }
}

struct TreasureChest: View {
    var body: some View {
        ZStack {
            // Coins pile
            HStack(spacing: -2) {
                Circle().fill(Color.gold).frame(width: 7, height: 7)
                Circle().fill(Color.gold).frame(width: 7, height: 7)
                Circle().fill(Color.gold).frame(width: 7, height: 7)
            }
            .offset(y: -15)

            // Body
            RoundedRectangle(cornerRadius: 3).fill(Color.chestBrown)
                .frame(width: 38, height: 22)
                .offset(y: 4)
            // Lid band
            Rectangle().fill(Color.sandMid)
                .frame(width: 38, height: 4)
                .offset(y: -3)
            // Lock
            RoundedRectangle(cornerRadius: 1).fill(Color.gold)
                .frame(width: 5, height: 9)
                .offset(y: 3)
        }
    }
}

// MARK: - River

struct RiverView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Light band
                Path { p in
                    p.move(to: CGPoint(x: w * 0.60, y: h * 0.31))
                    p.addCurve(to: CGPoint(x: w * 0.50, y: h * 0.46),
                                control1: CGPoint(x: w * 0.55, y: h * 0.36),
                                control2: CGPoint(x: w * 0.46, y: h * 0.40))
                    p.addCurve(to: CGPoint(x: w * 0.40, y: h * 0.72),
                                control1: CGPoint(x: w * 0.53, y: h * 0.55),
                                control2: CGPoint(x: w * 0.43, y: h * 0.62))
                    p.addCurve(to: CGPoint(x: w * 0.36, y: h),
                                control1: CGPoint(x: w * 0.38, y: h * 0.82),
                                control2: CGPoint(x: w * 0.39, y: h * 0.92))
                    p.addLine(to: CGPoint(x: w * 0.72, y: h))
                    p.addCurve(to: CGPoint(x: w * 0.63, y: h * 0.70),
                                control1: CGPoint(x: w * 0.66, y: h * 0.88),
                                control2: CGPoint(x: w * 0.62, y: h * 0.80))
                    p.addCurve(to: CGPoint(x: w * 0.66, y: h * 0.31),
                                control1: CGPoint(x: w * 0.66, y: h * 0.55),
                                control2: CGPoint(x: w * 0.60, y: h * 0.40))
                    p.closeSubpath()
                }
                .fill(Color.riverLight.opacity(0.6))

                // Dark part
                Path { p in
                    p.move(to: CGPoint(x: w * 0.50, y: h * 0.50))
                    p.addCurve(to: CGPoint(x: w * 0.42, y: h * 0.72),
                                control1: CGPoint(x: w * 0.50, y: h * 0.58),
                                control2: CGPoint(x: w * 0.45, y: h * 0.64))
                    p.addCurve(to: CGPoint(x: w * 0.38, y: h),
                                control1: CGPoint(x: w * 0.40, y: h * 0.82),
                                control2: CGPoint(x: w * 0.41, y: h * 0.92))
                    p.addLine(to: CGPoint(x: w * 0.58, y: h))
                    p.addCurve(to: CGPoint(x: w * 0.55, y: h * 0.70),
                                control1: CGPoint(x: w * 0.56, y: h * 0.88),
                                control2: CGPoint(x: w * 0.53, y: h * 0.80))
                    p.addCurve(to: CGPoint(x: w * 0.56, y: h * 0.50),
                                control1: CGPoint(x: w * 0.57, y: h * 0.62),
                                control2: CGPoint(x: w * 0.54, y: h * 0.56))
                    p.closeSubpath()
                }
                .fill(Color.riverDark.opacity(0.7))
            }
        }
    }
}

// MARK: - Eagle (low-poly, drawn in a 370 x 180 canvas)

struct EagleView: View {
    private func poly(_ pts: [(CGFloat, CGFloat)]) -> Path {
        Path { p in
            guard let first = pts.first else { return }
            p.move(to: CGPoint(x: first.0, y: first.1))
            for pt in pts.dropFirst() { p.addLine(to: CGPoint(x: pt.0, y: pt.1)) }
            p.closeSubpath()
        }
    }

    var body: some View {
        ZStack {
            // Wings
            poly([(0, 92), (135, 50), (160, 52), (168, 100)])
                .fill(Color(hex: 0x555B5E))
            poly([(370, 92), (235, 50), (210, 52), (202, 100)])
                .fill(Color(hex: 0x555B5E))
            poly([(40, 90), (135, 62), (160, 64), (166, 98)])
                .fill(Color(hex: 0x3F4548))
            poly([(330, 90), (235, 62), (210, 64), (204, 98)])
                .fill(Color(hex: 0x3F4548))

            // Tail
            poly([(172, 140), (200, 140), (200, 178), (172, 178)])
                .fill(Color(hex: 0x3A3D40))

            // Body
            poly([(185, 6), (203, 32), (214, 96), (200, 145), (170, 145), (156, 96), (167, 32)])
                .fill(Color(hex: 0xE8E8E4))
            // Body shade
            poly([(185, 32), (204, 52), (185, 100), (166, 52)])
                .fill(Color(hex: 0xD2D4D1))
            // Beak
            poly([(180, 8), (190, 0), (191, 12)])
                .fill(Color.gold)
        }
        .frame(width: 370, height: 180)
    }
}

// MARK: - Preview

#Preview {
    IslandsMapView { id in
        print("Selected island \(id)")
    }
}
