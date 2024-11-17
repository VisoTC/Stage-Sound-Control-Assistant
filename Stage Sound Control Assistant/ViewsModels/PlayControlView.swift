//
//  PlayControlView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/9.
//

import SwiftUI

struct PlayControlView: View {
    @EnvironmentObject private var musicStorage:MusicStorage
    @EnvironmentObject private var musicPlayer:MusicPlayer
    @EnvironmentObject private var config:Config
    @State private var normalVolume:Float = 1.0
    @State private var isSpeak = false
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: {
                    musicPlayer.startFadeIn()
                }) {
                    Text("淡入")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                }.disabled(musicPlayer.currentPlayMusic == nil).disabled(musicPlayer.isPlaying)
                Button(action: {
                    if musicPlayer.isPlaying{
                        musicPlayer.pause()
                    } else{
                        musicPlayer.play()
                    }
                    
                }) {
                    Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                }.disabled(musicPlayer.currentPlayMusic == nil)
                Button(action: {
                    musicPlayer.stop()
                }) {
                    Image(systemName:"stop.fill")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                }
                .disabled(musicPlayer.currentPlayMusic == nil)
                Button(action: {
                    musicPlayer.startFadeOut()
                }) {
                    Text("淡出")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                }.disabled(musicPlayer.currentPlayMusic == nil).disabled(!musicPlayer.isPlaying)
            }
            HStack(spacing: 10) {
                Button(action: {
                    musicPlayer.nextMusic()
                }) {
                    Text("下一曲")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                }
                Button(action: {
                    musicStorage.resetAllPlayed()}) {
                        Text("重置页面")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .cornerRadius(8)
                    }
                ZStack(alignment: .topLeading) {
                    Button(action: {
                        config.duckAudio.toggle()
                    }) {
                        HStack {
                            Circle()
                                .fill(config.duckAudio ? Color("Playing") : Color("Played"))
                                .frame(width: 10, height: 10)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                            Text("讲话避让")
                        }.frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
            }
            HStack(spacing: 10) {
                ZStack(alignment: .topLeading) {
                    Button(action: {
                        config.autoNextMusic.toggle()
                        config.save()
                    }) {
                        HStack {
                            Circle()
                                .fill(config.autoNextMusic ? Color("Playing") : Color("Played"))
                                .frame(width: 10, height: 10)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                            Text("连续播放")
                        }.frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
                ZStack(alignment: .topLeading) {
                    Button(action: {
                        config.loopPlay.toggle()
                        config.save()
                    }) {
                        HStack {
                            Circle()
                                .fill(config.loopPlay ? Color("Playing") : Color("Played"))
                                .frame(width: 10, height: 10)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                            Text("循环播放")
                        }.frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
                ZStack(alignment: .topLeading) {
                    Button(action: {
                        config.instantPlay.toggle()
                    }) {
                        HStack {
                            Circle()
                                .fill(config.instantPlay ? Color("Playing") : Color("Played"))
                                .frame(width: 10, height: 10)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                            Text("即点即播")
                        }.frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10.0).fill(Color("BackgroundColor"))
            
        )
    }
}

#Preview {
    PlayControlView()
        .environmentObject(MusicItemStorageFactory.shared)
        .environmentObject(MusicPlayer())
        .environmentObject(Config.shared)
}
