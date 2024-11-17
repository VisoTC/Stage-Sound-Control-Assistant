//
//  Stage_Sound_Control_AssistantApp.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/9.
//

import SwiftUI
import AVFoundation

@main
struct Stage_Sound_Control_AssistantApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindowsView()
                .environmentObject(MusicItemStorageFactory.shared)
                .environmentObject(MusicPlayer())
                .environmentObject(Config.shared)
                .environmentObject(CurrentOutputDevice.shared)
        }
    }
}
