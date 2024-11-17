//
//  MusicStorage.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import Foundation
import AVFoundation

class MusicStorage: ObservableObject{
    @Published var musicItems: [MusicItem?]
    @Published var editMusicItem: MusicItem?{
        didSet {
            isEditMusicItem = editMusicItem != nil
        }
    }
    
    @Published var isEditMusicItem: Bool = false
    
    init() {
        musicItems = Array<MusicItem?>(repeating: nil, count: 48)
    }
    //交换音乐
    func switchItems(at indexA: Int, with indexB: Int) {
        guard indexA >= 0, indexA < musicItems.count,
              indexB >= 0, indexB < musicItems.count else {
            print("索引超出范围")
            return
        }
        (self.musicItems[indexA], self.musicItems[indexB]) = (self.musicItems[indexB], self.musicItems[indexA])
    }
    //添加音乐
    func addMusicItems(from startIndex: Int, urls: [URL]) {
        guard startIndex >= 0, startIndex < musicItems.count else {
            print("输入的开始索引无效")
            return
        }
        Task{
            for (offset, url) in urls.enumerated() {
                if startIndex + offset < musicItems.count {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource()}
                        do{
                            let musicItem = MusicItem(name: url.lastPathComponent, duration: try await Int(getMediaDuration(url:url)),url:url)
                            DispatchQueue.main.async{
                                self.musicItems[startIndex + offset] = musicItem
                            }
                        }catch{
                            print("读取音频失败：\(error.localizedDescription)")
                        }
                    }
                }
            }
            DispatchQueue.main.async{
                MusicItemStorageFactory.save(musicStorage: self)
            }
            
        }
    }
    func changeFile(at index:Int,url:URL) async {
        guard self.musicItems[index] != nil else{
            return
        }
        return await changeFile(musicItem: self.musicItems[index]!, url: url)
    }
    func changeFile(musicItem:MusicItem,url:URL) async {
        print("正在修改文件")
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource()}
            do{
                let duration = try await Int(getMediaDuration(url:url))
                DispatchQueue.main.async{
                    musicItem.duration = duration
                    musicItem.url = url
                    musicItem.createSecurityScopedURLBookmarkData()
                }
            }catch{
                print("读取音频失败：\(error.localizedDescription)")
            }
        }
        print("修改文件完成")
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.save()
        }
    }
    func nextMusicItem(item: MusicItem) -> MusicItem? {
        let items = musicItems.filter({ $0 != nil && ($0 == item || $0!.status == .NotPlayed) }) // 过滤非 nil 项和非未播项
        guard let currentIndex = items.firstIndex(of: item) else {
            return nil // 如果找不到当前项，返回 nil
        }
        
        // 判断是否存在下一个元素
        if currentIndex + 1 < items.count {
            return items[currentIndex + 1] // 返回下一个元素
        } else {
            return nil // 已是最后一个元素
        }
    }
    
    func resetAllPlayed(){
        musicItems.forEach{ $0?.isPlaying = false}
        objectWillChange.send()
    }
    
    //清除音乐
    func clear(at index:Int){
        guard index >= 0, index < musicItems.count else {
            print("索引超出范围")
            return
        }
        if musicItems[index] == nil {
            print("本来就没东西")
            return
        }
        self.musicItems[index] = nil
    }
    func clearAllItem(){
        for index in self.musicItems.indices{
            self.musicItems[index] = nil
        }
    }
    
    private func getMediaDuration(url:URL) async throws -> Double {
        let asset = AVURLAsset(url: url)
        do{
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        }catch {
            print("加载持续时间时出错：\(error.localizedDescription)")
            throw error
        }
    }
    func save(){
        MusicItemStorageFactory.save(musicStorage: self)
    }
}


