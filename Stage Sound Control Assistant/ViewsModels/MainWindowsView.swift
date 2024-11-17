//
//  MainView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/9.
//

import SwiftUI

struct MainWindowsView: View {
    @State private var isSettingsPresented = false
    @EnvironmentObject private var config:Config
    @EnvironmentObject private var currentOutputDevice:CurrentOutputDevice
    var deviceIconName: String {
            // 根据设备类型选择图标名称
            #if os(macOS)
            return "laptopcomputer"
            #else
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return "device.phone"
            case .pad:
                return "device.tablet"
            default:
                return "desktopcomputer"
            }
            #endif
        }
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack{
                    PlayControlView()
                        .frame(maxWidth: .infinity)
                    PlayInfoView()
                        .frame(maxWidth: .infinity)
                }
                .padding([.top, .leading, .trailing])
                .padding( .bottom, 0)
                .frame(height: 260)
                MusicPanel()
                    .padding(0.0)
                
            }
            .navigationTitle("舞台音控助手")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .automatic) {
                    AirPlayButton()
                }
#endif
                ToolbarItem(placement: .automatic) {
                    HStack(){
                        Image(systemName: currentOutputDevice.currentOutputDeviceType == .AirPlay ? "tv.and.hifispeaker.fill" : "hifispeaker.arrow.forward")
                        Text(currentOutputDevice.currentOutputDeviceName)
                            .lineLimit(1).layoutPriority(1)
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gearshape") // 设置按钮图标
//                            .font(.title2)
                    }
                }
            }
            .frame(minWidth: 800,minHeight: 600.0)
           
            .sheet(isPresented: $isSettingsPresented, onDismiss: {
                config.save()
            }) {
                ConfigWindowsView()
            }
        }
    }
}

#Preview {
    MainWindowsView()
        .environmentObject(MusicItemStorageFactory.shared)
        .environmentObject(MusicPlayer())
        .environmentObject(Config.shared)
        .environmentObject(CurrentOutputDevice.shared)
}
