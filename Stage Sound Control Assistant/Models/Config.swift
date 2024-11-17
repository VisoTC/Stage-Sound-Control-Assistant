//
//  Config.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import Foundation

class Config: Codable, ObservableObject {
    static let shared = Config.create() // 单例实例
    
    @Published var fadeInDuration: Int = 20 // 淡入时间
    @Published var fadeOutDuration: Int = 20 // 淡入时间
    @Published var fadeWithDuckAudio: Int = 20 // 讲话避让淡入时间
    @Published var autoNextMusic = false // 连续播放
    @Published var loopPlay = false // 循环播放
    @Published var instantPlay = false // 即点即播
    @Published var duckAudio = false // 说话回避
    @Published var volume:Int = 100 //播放音量
    @Published var speakVolume:Int = 100 //讲话音量

    
    enum CodingKeys: String, CodingKey {
        case fadeInDuration, fadeOutDuration, autoNextMusic, speakVolume,volume, loopPlay,instantPlay,duckAudio,fadeWithDuckAudio
    }
    private init() {}
    // 手动实现解码
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fadeInDuration = try container.decode(Int.self, forKey: .fadeInDuration)
        fadeOutDuration = try container.decode(Int.self, forKey: .fadeOutDuration)
        fadeWithDuckAudio = try container.decode(Int.self, forKey: .fadeWithDuckAudio)
        instantPlay = try container.decode(Bool.self, forKey: .instantPlay)
        autoNextMusic = try container.decode(Bool.self, forKey: .autoNextMusic)
        loopPlay = try container.decode(Bool.self, forKey: .loopPlay)
        duckAudio = try container.decode(Bool.self, forKey: .duckAudio)
        volume = try container.decode(Int.self, forKey: .volume)
        speakVolume = try container.decode(Int.self, forKey: .speakVolume)
    }
    
    // 手动实现编码
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fadeInDuration, forKey: .fadeInDuration)
        try container.encode(fadeOutDuration, forKey: .fadeOutDuration)
        try container.encode(fadeWithDuckAudio, forKey: .fadeWithDuckAudio)
        try container.encode(autoNextMusic, forKey: .autoNextMusic)
        try container.encode(loopPlay, forKey: .loopPlay)
        try container.encode(instantPlay, forKey: .instantPlay)
        try container.encode(duckAudio, forKey: .duckAudio)
        try container.encode(volume, forKey: .volume)
        try container.encode(speakVolume, forKey: .speakVolume)
    }
    
    private static let filename = "config.json"
    
    private static var filePath: URL {
        // 获取应用的私有路径
        let documentsURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(filename)
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: Config.filePath)
            print("设置保存成功！路径：\(Config.filePath)")
        } catch {
            print("保存设置失败：\(error)")
        }
    }

    static func create() -> Config {
        do {
            let data = try Data(contentsOf: filePath)
            let config = try JSONDecoder().decode(Config.self, from: data)
            return config
        } catch {
            print("加载设置失败：\(error)")
            try? FileManager.default.removeItem(at: filePath)
            return Config()
        }
    }
}
