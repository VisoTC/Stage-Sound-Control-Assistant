//
//  MusicItemStorageFactory.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import Foundation

class MusicItemStorageFactory {
    static let shared = MusicItemStorageFactory.create() // 单例实例
    
    static let fileManager = FileManager.default
    static private let filename = "musicItemStorage.json"
    static private var filePath: URL {
        // 获取应用的私有路径
        let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return applicationSupportURL.appendingPathComponent(filename)
    }

    static func save(musicStorage: MusicStorage) {
        do {
            let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            if !fileManager.fileExists(atPath: supportDirectory.path) {
                try? fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let items = musicStorage.musicItems
            let data = try JSONEncoder().encode(items)
            try data.write(to: filePath)
            print("数据保存成功！路径：\(filePath)")
        } catch {
            print("保存数据失败：\(error)")
        }
    }

    static func create() -> MusicStorage {
        let newMusicStorage = MusicStorage()
        do {
            let data = try Data(contentsOf: filePath)
            let items = try JSONDecoder().decode([MusicItem?].self, from: data)
            newMusicStorage.musicItems = items.map { item in
                    item?.restoreSecurityScopedURL()
                    return item
            }
            return newMusicStorage
        } catch {
            print("加载数据失败：\(error)")
            return newMusicStorage
        }
    }
    static func initStorage(){
        if fileManager.fileExists(atPath: filePath.path) {
            if (try? fileManager.removeItem(at: filePath)) != nil {
                print("已删除储存")
            }else{
                print("删除储存失败")
            }
        }
        MusicItemStorageFactory.shared.clearAllItem()
    }
}
