//
//  ExtensionView.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import SwiftUI

extension View {
    // 自定义 View 扩展来实现条件隐藏
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}
