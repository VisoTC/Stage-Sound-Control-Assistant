//
//  PlayInfoView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/9.
//

import SwiftUI

struct PlayInfoView: View {
    @EnvironmentObject private var musicPlayer:MusicPlayer
    @EnvironmentObject private var config:Config
    @State private var musicName:String = "尚未播放曲目"
    @State private var isEditCurrentTimeing = false{
        didSet{ // 修复iPad进度条不跟手
            if isEditCurrentTimeing == false && tempCurrentTime != -1  {
                musicPlayer.setCurrentTime(currentTime: tempCurrentTime)
                musicPlayer.update()
                tempCurrentTime = -1
            }
        }
    }
    @State private var tempCurrentTime:TimeInterval = -1
    private var currentTime: Binding<TimeInterval> {
        Binding(
            get: {
                if tempCurrentTime == -1 {
                    return musicPlayer.currentTime
                }else{
                    return tempCurrentTime
                }
            },
            set: { newValue in
                if isEditCurrentTimeing == false{
                    musicPlayer.setCurrentTime(currentTime: newValue)
                }else{
                    tempCurrentTime = newValue
                }
            }
        )
    }
    var body: some View{
        HStack{
            VStack(spacing: 20) {
                // 时长显示部分
                HStack {
                    VStack {
                        Text("总共时长")
                        Text(timeString(from: musicPlayer.totalDuration))
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                        .frame(height: 45)
                    VStack {
                        Text("已播放时长")
                        Text(timeString(from: musicPlayer.currentTime))
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    Divider().frame(height: 45)
                    VStack {
                        Text("剩余时长")
                        Text(timeString(from: musicPlayer.remainingTime))
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                //播放进度滑块与状态显示
                HStack {
                    Slider(value: currentTime, in: 0...musicPlayer.totalDuration, onEditingChanged: {isEditing in
                        self.isEditCurrentTimeing = isEditing
                        
                    })
                    .padding(.vertical, 8.0)
                    Divider().frame(height: 20)
                    Image(systemName: "repeat")
                        .foregroundColor(config.autoNextMusic ? .accentColor : .gray ) //连续播放
                    Divider().frame(height: 20)
                    Image(systemName: "repeat.1")
                        .foregroundColor(config.loopPlay ? .accentColor : .gray )//循环播放
                    Divider().frame(height: 20)
                    Image(systemName: "rectangle.and.hand.point.up.left")
                        .foregroundColor(config.instantPlay ? .accentColor : .gray )//循环播放
                }
                
                
                
                // 音量控制滑块
                HStack {
                    SpeakerImage(volume: $musicPlayer.volume)
                    Slider(value: Binding(get: {
                        Float(musicPlayer.volume)  // 将 Int 转换为 Float
                    }, set: { newValue in
                        musicPlayer.volume = Int(newValue)  // 将 Float 转换为 Int
                        musicPlayer.objectWillChange.send()
                    }), in: 0...100).disabled(musicPlayer.isFadeing)
                    Text(String(format: "%d%%", Int(musicPlayer.volume)))
                    Divider().frame(height: 20)
                    Image(systemName: "music.microphone")
                        .foregroundColor(config.duckAudio ? .accentColor : .gray )//讲话避让
                }
                .padding(.bottom, 8.0)
                // 曲目信息
                Text(musicPlayer.currentPlayMusic?.name ?? "尚未播放曲目")
            }
            AudioMeterView().padding(.bottom, 0.0)
        }.frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10.0).fill(Color("BackgroundColor"))
            
        )
    }
    
    // 将秒转换为时间字符串（mm:ss）
    func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayInfoView()
        .environmentObject(MusicPlayer())
        .environmentObject(Config.shared)
}
