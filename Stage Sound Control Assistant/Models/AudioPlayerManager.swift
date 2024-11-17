//
//  AudioPlayerManager.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import AVFoundation

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    
    private var didFinishPlayingHandles:[(AVAudioPlayer, Bool) -> Void] = []
    
    func addDidFinishPlayingHandles(_func: @escaping (AVAudioPlayer, Bool) -> Void){
        didFinishPlayingHandles.append(_func)
    }
    
    // 检查是否播放结束
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for handle in didFinishPlayingHandles {
               handle(player, flag)
           }
    }
}
