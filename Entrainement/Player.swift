//
//  Player.swift
//
//  Created by Arthur Rolland on 08/03/2018.
//  Copyright © 2018 Arthur Rolland. All rights reserved.
//


// ReadMe
//
// ------------------------------------------------
//
// To use this class, Simply add it to your project.
// -    When you have Audio data to play, just call Player.shared.playSound(_yourDataObjectHere)
// -    If you call playSound before the end of the previous sound playback, your sound data are enqueued and will be played after.
// -    To stop the playback and purge the queue, just call Player.shared.stop()
//
// Enjoy ;)
//
// ------------------------------------------------


import Foundation
import AVFoundation

class Player: NSObject, AVAudioPlayerDelegate {
    
    // MARK: - Public API
    static let shared = Player()
    
    func playSound(_ data: Data) {
        self.enqueueSound(data)
    }
    
    func stop() {
        self.queue = [Data]()
        self.player?.stop()
        self.player = nil
    }
    
    
    // MARK: - Private
    private override init() {}
    
    private var player: AVAudioPlayer?
    private var queue = [Data]()
    
    private func enqueueSound(_ data: Data) {
        self.queue.insert(data, at: 0)
        if self.player == nil || !self.player!.isPlaying {
            self.playNext()
        }
    }
    
    private func playNext() {
        self.player?.stop()
        self.player = nil
        
        if let data = self.queue.popLast() {
            if let player = try? AVAudioPlayer(data: data) {
                self.player = player
                self.player?.delegate = self
                self.player?.numberOfLoops = 0
                self.player?.volume = 1
                if self.player!.prepareToPlay() {
                    self.player?.play()
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playNext()
    }
}
