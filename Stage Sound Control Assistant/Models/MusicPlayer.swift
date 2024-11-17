//
//  MusicPlayer.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class MusicPlayer: ObservableObject{
    private var player: AVAudioPlayer?
    
    private var timer: Timer?
    private var fadeTimer: Timer?{
        didSet{
            isFadeing = fadeTimer != nil
        }
    }
    private let audioPlayerManager:AudioPlayerManager
    private let config = Config.shared

    @Published var isPlaying = false
    @Published var currentPlayMusic: MusicItem? = nil {
        didSet {
            if currentPlayMusic != oldValue {
                volumeSig.toggle()
            }
        }
    }

    @Published var volume: Int = 100 {
        didSet {
            if volume != oldValue {
                volumeSig.toggle()
            }
        }
    }
    let saveVolumeSettingdebouncer = Debouncer(delay: 1.0) // 延迟 1 秒
    
    @Published var volumeSig = false {
        didSet {
            player?.volume = Float(volume * (currentPlayMusic?.volume ?? 100)) / 100
            saveVolumeSettingdebouncer.execute { [weak self] in
                guard let self = self else { return }
                if self.config.duckAudio {
                    if self.config.speakVolume != self.volume {
                        self.config.speakVolume = self.volume
                    }
                } else {
                    if self.config.volume != self.volume {
                        self.config.volume = self.volume
                    }
                }
                self.config.objectWillChange.send()
                self.config.save()
                print("volume:", self.volume, "speakVolume:", self.config.speakVolume)
            }
        }
    }
    @Published var isFadeing = false
    
    @Published var currentTime: TimeInterval = 0.0 {
            didSet {
                //player?.currentTime = currentTime
            }
        }
    @Published var totalDuration: TimeInterval = 0.0
    @Published var remainingTime: TimeInterval = 0.0
    
    private var cancellableDuckAudio: AnyCancellable? // 用于存储订阅
    
    @Published var currentLevel:Float = 0.0
    
    init() {
        self.audioPlayerManager = AudioPlayerManager()
        self.audioPlayerManager.addDidFinishPlayingHandles(_func: isStop)
        
        self.volume = config.duckAudio ? config.speakVolume: config.volume
        
        cancellableDuckAudio = config.$duckAudio.sink { newValue in
            if self.isPlaying {
                self.startFade(to: (newValue ? self.config.speakVolume: self.config.volume), duration: self.config.fadeWithDuckAudio){
                    self.volumeSig.toggle()
                }
            }else{
                self.volume = newValue ? self.config.speakVolume: self.config.volume
                self.volumeSig.toggle()
            }
        }
    }
    
    func load(musicItem:MusicItem) {
        do {
            if(!musicItem.isExists()){
                return
            }
            currentPlayMusic = musicItem
            if currentPlayMusic!.url!.startAccessingSecurityScopedResource() {
                defer { currentPlayMusic!.url!.stopAccessingSecurityScopedResource()}
                player = try AVAudioPlayer(contentsOf: currentPlayMusic!.url!)
                player!.isMeteringEnabled = true
#if os(iOS)
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay])
                    try audioSession.setActive(true)
                } catch {
                    print("Failed to set audio session category and activate session:", error)
                }
#endif
                player!.delegate = audioPlayerManager
                player!.prepareToPlay()
                update()
            }
        } catch {
            print("无法播放音频文件: \(error.localizedDescription)")
        }
    }
    
    func play() {
        guard player != nil else {
            print ("播放器未准备好")
            return
        }
        player!.play()
        currentPlayMusic!.isPlaying = true
        MusicItemStorageFactory.shared.save()
        startTimer()
    }
    func stop() {
        guard player != nil else {
            print ("播放器未准备好")
            return
        }
        player!.stop()
        player = nil
        currentPlayMusic = nil
        isPlaying = false
        
        totalDuration = 0
        currentTime = 0
        remainingTime = 0
        
        stopTimer()
    }
    func pause(){
        guard player != nil else {
            print ("播放器未准备好")
            return
        }
        player!.pause()
        update()
    }
    
    func nextMusic(){
        if currentPlayMusic != nil{
            let nextMusic = MusicItemStorageFactory.shared.nextMusicItem(item: currentPlayMusic!)
            if nextMusic != nil{
                load(musicItem: nextMusic!)
                play()
            }else{
                print("没有下一首了")
            }
        }
    }
    
    func setCurrentTime(currentTime:TimeInterval){
        guard player != nil else {
            print ("播放器未准备好")
            return
        }
        player!.currentTime = currentTime
        print(player!.currentTime)
    }
    func startFade(to targetVolume: Int, duration: Int, completion: (() -> Void)? = nil) {
        guard player != nil else { return }
        guard fadeTimer == nil else {
            print("已经有在淡入淡出的操作了")
            return
        }
        let _duration = Double(duration) / 10
        let initialVolume = self.volume
        // 计算每次音量增加的量
        let fadeSteps = Int(duration / 1)
        let volumeIncrement = (targetVolume - initialVolume) / fadeSteps
        fadeTimer = Timer.scheduledTimer(withTimeInterval: _duration / Double(fadeSteps), repeats: true) { timer in
            if (volumeIncrement > 0 && self.volume < targetVolume) || (volumeIncrement < 0 && self.volume > targetVolume) {
                self.volume += volumeIncrement
            } else {
                self.volume = targetVolume
                timer.invalidate()
                self.fadeTimer = nil
                completion?() // 调用完成闭包
            }
        }
    }
    
    func startFadeIn() {
        let volume = self.volume
        self.volume = 0
        self.play()
        startFade(to:volume ,duration:config.fadeInDuration)
    }
    
    func startFadeOut() {
        let volume = self.volume
        startFade(to:0 ,duration:config.fadeInDuration){
            self.pause()
            self.volume = volume
        }
        
    }
    
    private func isStop(_:AVAudioPlayer, _:Bool){
        if(config.loopPlay){
            play()
            return
        }
        if(config.autoNextMusic){
            nextMusic()
            return
        }
        self.stop()
        
    }
    
    private func startTimer() {
        stopTimer()
        update()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.update()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    func update() {
        guard let player = player else { return }
        
        totalDuration = player.duration
        currentTime = player.currentTime
        remainingTime = totalDuration - currentTime
        isPlaying = player.isPlaying
        
        player.updateMeters()
        let power = player.peakPower(forChannel: 0)
        self.currentLevel = self.normalizeSoundLevel(level: power)
        
    }
    
        
    private func normalizeSoundLevel(level: Float) -> Float {
        let minLevel: Float = -80.0 // 最低电平，表示无声
        let maxLevel: Float = 0.0   // 最高电平，表示最大音量

        // 将 level 限制在 minLevel 和 maxLevel 范围内
        let clampedLevel = max(minLevel, min(level, maxLevel))

        // 进行标准化，将 clampedLevel 映射到 0 到 1 的范围
        let normalizedLevel = (clampedLevel - minLevel) / (maxLevel - minLevel)

        // 应用曲线调整：将标准化的电平值转换为接近线性感知的曲线
        return pow(normalizedLevel, 2)
    }
    
}
