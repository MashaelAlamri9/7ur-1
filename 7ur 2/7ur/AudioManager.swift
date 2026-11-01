//
//  AudioManager.swift
//  7ur
//
//  Created by Mashael on 17/05/1448 AH.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine
@MainActor
final class AudioManager: ObservableObject {

    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [String: AVAudioPlayer] = [:]

    @AppStorage("musicVolume") private var musicVolume: Double = 0.7
    @AppStorage("musicAllowed") private var musicAllowed = true

    @AppStorage("sfxVolume") private var sfxVolume: Double = 0.55
    @AppStorage("sfxAllowed") private var sfxAllowed = true

    private init() {}

    // MARK: - Background Music

    func startMusic() {
        guard musicAllowed else {
            stopMusic()
            return
        }

        if let player = musicPlayer, player.isPlaying {
            player.volume = Float(musicVolume)
            return
        }

        guard let url = Bundle.main.url(
            forResource: "island_music",
            withExtension: "mp3"
        ) else {
            print("Audio error: island_music.mp3 not found")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = Float(musicVolume)
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Music playback error: \(error.localizedDescription)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
    }

    func updateMusicSettings() {
        guard musicAllowed else {
            stopMusic()
            return
        }

        if musicPlayer == nil {
            startMusic()
        }

        musicPlayer?.volume = Float(musicVolume)

        if musicPlayer?.isPlaying == false {
            musicPlayer?.play()
        }
    }

    // MARK: - Sound Effects


    func playSound(_ name: String) {
        guard sfxAllowed else { return }

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "mp3"
        ) else {
            print("Sound error: \(name).mp3 not found")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = Float(sfxVolume)
            player.prepareToPlay()

            soundPlayers[name] = player
            player.play()
        } catch {
            print("Sound playback error: \(error.localizedDescription)")
        }
    }

    func updateSoundSettings() {
        for player in soundPlayers.values {
            player.volume = sfxAllowed ? Float(sfxVolume) : 0
        }

        if !sfxAllowed {
            soundPlayers.removeAll()
        }
    }
}
