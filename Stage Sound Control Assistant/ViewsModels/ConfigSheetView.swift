//
//  ConfigWindowsView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import SwiftUI

struct ConfigWindowsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var config:Config
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            List() {
                // 淡入持续时间设置
                Section(){
                    HStack {
                        Text("淡入持续时间: ")
                        Slider(value:Binding(get: {
                            Float(config.fadeInDuration)  // 将 Int 转换为 Float
                        }, set: { newValue in
                            config.fadeInDuration = Int(newValue)// 将 Float 转换为 Int
                            config.objectWillChange.send()
                        }), in: 0...100)
                        Text(String(format: "%.1f秒", Float(config.fadeInDuration) / 10))
                    }
                    
                    // 淡出持续时间设置
                    HStack {
                        Text("淡出持续时间: ")
                        Slider(value: Binding(get: {
                            Float(config.fadeOutDuration)  // 将 Int 转换为 Float
                        }, set: { newValue in
                            config.fadeOutDuration = Int(newValue)  // 将 Float 转换为 Int
                            config.objectWillChange.send()
                        }), in: 0...100)
                        Text(String(format: "%.1f秒", Float(config.fadeOutDuration) / 10))
                    }
                    // 讲话避让持续时间设置
                    HStack {
                        Text("讲话避让转换时间: ")
                        Slider(value: Binding(get: {
                            Float(config.fadeWithDuckAudio)  // 将 Int 转换为 Float
                        }, set: { newValue in
                            config.fadeWithDuckAudio = Int(newValue)  // 将 Float 转换为 Int
                            config.objectWillChange.send()
                        }), in: 0...100)
                        Text(String(format: "%.1f秒", Float(config.fadeWithDuckAudio) / 10))
                    }
                }
                Section(){
                    // 音量设置
                    HStack {
                        Text("音量: ")
                        Slider(value:Binding(get: {
                            Float(config.volume)  // 将 Int 转换为 Float
                        }, set: { newValue in
                            config.volume = Int(newValue)  // 将 Float 转换为 Int
                            config.objectWillChange.send()
                        }), in: 0...100)
                        Text("\(config.volume)%")
                    }
                    HStack {
                        Text("讲话音量: ")
                        Slider(value: Binding(get: {
                            Float(config.speakVolume)  // 将 Int 转换为 Float
                        }, set: { newValue in
                            config.speakVolume = Int(newValue)  // 将 Float 转换为 Int
                            config.objectWillChange.send()
                        }), in: 0...100)
                        Text("\(config.speakVolume)%")
                    }
                }
                
            }
            .padding()
            .frame(minHeight: 300)
            .navigationTitle("系统设置")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("确认删除所有数据？"),
                    message: Text("此操作无法撤销。"),
                    primaryButton: .destructive(Text("删除")) {
                        MusicItemStorageFactory.initStorage()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("关闭")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("删除所有配置").foregroundColor(.red)
                    }
                }
                
            }
        }
        
    }
}

#Preview {
    ConfigWindowsView()
        .environmentObject(Config.shared)
}
