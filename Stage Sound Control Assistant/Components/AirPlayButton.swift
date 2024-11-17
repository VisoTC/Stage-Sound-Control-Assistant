//
//  AirPlayButton.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/12.
//
import Foundation
import SwiftUI
import AVKit

#if os(iOS)
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        routePickerView.activeTintColor = .systemBlue  // 设置激活时的图标颜色
        routePickerView.tintColor = .systemGray        // 设置普通状态的图标颜色
        return routePickerView
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        // 不需要更新视图
    }
}
#endif
