import SwiftUI

enum Screen: Hashable { case welcome, userName, avatar, map, challenge, board, settings }

struct RootView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var screen: Screen
    @State private var island = 1
    @ObservedObject private var wardrobe = AvatarWardrobe.shared

    init() {
        let done = UserDefaults.standard.bool(forKey: "hasOnboarded")
        _screen = State(initialValue: done ? .map : .welcome)
    }

    private func go(_ s: Screen) {
        withAnimation(.easeInOut(duration: 0.3)) { screen = s }
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            switch screen {
            case .welcome:
                WelcomeView(onStart: { go(hasOnboarded ? .map : .userName) })

            case .userName:
                UserNameView(points: wardrobe.points) { name in
                    let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let final = t.isEmpty ? "Player" : t
                    userName = final
                    Task { @MainActor in BoardStore.shared.setName(final) }
                    go(.avatar)
                }

            case .avatar:
                AvatarCustomizerView(
                    onBack: { go(hasOnboarded ? .map : .userName) },
                    onConfirm: { _ in
                        hasOnboarded = true
                        go(.map)
                    })

            case .map:
                IslandsMapView(
                    userName: userName.isEmpty ? "Player" : userName,
                    coins: wardrobe.points,
                    onSelectIsland: { id in island = id; go(.challenge) },
                    onOpenBoard: { go(.board) },
                    onOpenAvatar: { go(.avatar) },
                    onOpenSettings: { go(.settings) })

            case .challenge:
                ChallengeView(islandId: island, onBack: { go(.map) })
                    .id(island)

            case .board:
                BoardView(onBack: { go(.map) })

            case .settings:
                SettingsView(onBack: { go(.map) })
            }
        }
        .transition(.opacity)
    }
}
