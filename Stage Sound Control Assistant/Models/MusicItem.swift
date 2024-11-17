//
//  MusicItem.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/9.
//

import Foundation

enum MusicItemError: Error {
    case FileIsStale
}

enum MusicItemStatus{
    case Invalidation
    case NotPlayed
    case Playing
    case Played
}

class MusicItem: ObservableObject, Identifiable, Equatable, Codable {
    @Published private(set) var id: UUID
    @Published var url: URL?
    @Published var bookmarkData: Data?
    @Published var name: String
    @Published var duration: Int
    @Published var volume:Int = 100
    @Published var isPlaying: Bool = false
    
    var status: MusicItemStatus {
        if url == nil {
            return .Invalidation
        }
        return isPlaying ? .Played : .NotPlayed
    }
    
    // 初始化方法
    init(name: String, duration: Int, isPlaying: Bool = false,id:UUID?=nil,bookmarkData:Data?=nil,url: URL?=nil ) {
        self.id = id ?? UUID()
        self.url = url
        self.name = name
        self.duration = duration
        self.isPlaying = isPlaying
        if (bookmarkData == nil && url != nil){
            self.createSecurityScopedURLBookmarkData()
        }else{
            self.bookmarkData = bookmarkData ?? Data()
        }
    }
    // 编解码实现
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case bookmarkData
        case name
        case duration
        case volume
        case isPlaying
    }
    
    // 编码方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // 编码所有属性
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(bookmarkData, forKey: .bookmarkData)
        try container.encode(name, forKey: .name)
        try container.encode(duration, forKey: .duration)
        try container.encode(volume, forKey: .volume)
        try container.encode(isPlaying, forKey: .isPlaying)
    }
    
    // 解码方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解码所有属性
        id = try container.decode(UUID.self, forKey: .id)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
        name = try container.decode(String.self, forKey: .name)
        duration = try container.decode(Int.self, forKey: .duration)
        volume = try container.decode(Int.self, forKey: .volume)
        isPlaying = try container.decode(Bool.self, forKey: .isPlaying)
    }
    

    // 实现 Equatable 协议
    static func == (lhs: MusicItem, rhs: MusicItem) -> Bool {
        return lhs.id == rhs.id
    }
    func isExists()  -> Bool{
        guard url != nil else{
            print("文件已经失效")
            return false
        }
        if url!.startAccessingSecurityScopedResource() {
            defer { url?.stopAccessingSecurityScopedResource()}
            if(!FileManager.default.fileExists(atPath: url!.path)){
                url = nil
                print("文件已经失效")
                return false
            }
        }
        return true
    }
    func createSecurityScopedURLBookmarkData(){
        if url!.startAccessingSecurityScopedResource() {
            defer { url!.stopAccessingSecurityScopedResource() }
            #if os(macOS)
            self.bookmarkData = try! url!.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
            #else
            self.bookmarkData = try! url!.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
            #endif
        }else{
            self.bookmarkData = nil
        }
    }
    func restoreSecurityScopedURL(){
        guard bookmarkData != nil else{
            return
        }
            do {
                var isStale = false
                // 从 Bookmark Data 恢复 URL
                #if os(macOS)
                let restoredURL = try URL(resolvingBookmarkData: bookmarkData!, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                #else
                let restoredURL = try URL(resolvingBookmarkData: bookmarkData!, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                #endif
                
                
                // 检查 URL 是否过期
                if isStale {
                    print("安全范围 URL 已过期")
                    self.url = nil
                }else{
                    self.url = restoredURL
                }
            } catch {
                print("恢复安全范围 URL 失败: \(error)")
            }
    }
}
