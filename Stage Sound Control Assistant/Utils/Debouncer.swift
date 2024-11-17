//
//  Debouncer.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/12.
//

import Foundation

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func execute(action: @escaping () -> Void) {
        // 取消之前的任务
        workItem?.cancel()
        
        // 创建一个新的任务
        workItem = DispatchWorkItem { action() }
        
        // 在指定延迟后执行新的任务
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
