//
//  AudioMeterView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/14.
//

import SwiftUI

struct AudioMeterView: View {
    @EnvironmentObject private var musicPlayer:MusicPlayer
    var body: some View {
        VStack {
            HStack {
                // 电平指示器
                ZStack(alignment: .bottom) {
                    // 灰色背景条，表示最大电平
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 20)
                        .cornerRadius(4)
                    
                    // 绿色动态电平条，表示当前音量
                    GeometryReader { geometry in
                        let parentHeight = geometry.size.height
                        VStack{
                            Spacer()
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 20, height: CGFloat(musicPlayer.currentLevel) * parentHeight) // 计算动态高度
                                .cornerRadius(4)
                                .animation(.linear, value: musicPlayer.currentLevel) // 平滑动画
                        }
                        
                    }
                    .frame(width: 20) // 限制 GeometryReader 的宽度
                }
            }
            Image(systemName: "waveform")
        }
    }
}

#Preview {
    AudioMeterView()
        .environmentObject(MusicPlayer())
}
