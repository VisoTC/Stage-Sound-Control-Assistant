import SwiftUI
import UniformTypeIdentifiers

struct MusicPanel: View {
    @EnvironmentObject private var musicStorage:MusicStorage
    @EnvironmentObject private var musicPlayer:MusicPlayer
    @EnvironmentObject private var config:Config
    @State private var showFileImporter = false
    @State private var fileAddIndex = -1
    @State private var showMusicItemSetting = false
    @State private var Clipboard:Int? = nil
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 6)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(musicStorage.musicItems.indices, id: \.self) { index in
                    ZStack(alignment: .center) {
                        if let music = musicStorage.musicItems[index] {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    music.status == MusicItemStatus.Invalidation
                                    ? Color("Invalidation")
                                    : (music.status == MusicItemStatus.NotPlayed
                                       ? Color("ButtonColor")
                                       : (music == musicPlayer.currentPlayMusic ? Color("Playing") : Color("Played")
                                         )
                                      )
                                )
                                .stroke(Color("Select"), lineWidth: music == musicPlayer.currentPlayMusic ? 2 : 0)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                                .aspectRatio(2, contentMode: .fit)
                            
                            VStack {
                                Text(music.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxHeight: .infinity,alignment: .topLeading)
                                    .padding(5.0)
                                
                            }
                            HStack{
                                Text(music.status == MusicItemStatus.Invalidation ? "文件已失效" : timeString(from: Double(music.duration)))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    
                                Spacer()
                                if(music.status != MusicItemStatus.Invalidation && music.volume != 100){
                                    HStack(spacing: 3.0){
                                        Image(systemName: "speaker.circle")
                                            .foregroundStyle(.secondary)
                                        Text(String(music.volume))
                                            .font(.subheadline)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Image(systemName: music.status == MusicItemStatus.Invalidation
                                      ? "trash.circle"
                                      : (music.status == MusicItemStatus.NotPlayed
                                         ? "circle"
                                         : (music == musicPlayer.currentPlayMusic ? (
                                            Config.shared.loopPlay ? "repeat.1.circle" : "play.circle"
                                         ) : "checkmark.circle"
                                         )
                                        ))
                                .foregroundStyle(.secondary)
                            }
                            .padding(5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    Color("ButtonColor")
                                )
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                                .aspectRatio(2, contentMode: .fit)
                        }
                        
                    }
                    .onTapGesture {
                        handleMusicTap(at: index)
                    }
                    .contextMenu{
                        Button(action: {
                            showFileImporter = true
                            fileAddIndex = index
                        }) {
                            Text("添加音乐")
                            Image(systemName: "plus")
                        }.disabled(musicStorage.musicItems[index] != nil)
                        
                        Divider()
                        Button(action: {
                            musicStorage.editMusicItem = musicStorage.musicItems[index]
                        }) {
                            Text("编辑")
                            Image(systemName: "pencil.line")
                        }.disabled(musicStorage.musicItems[index] == nil)
                        Divider()
                        Button(action: {
                            Clipboard = index
                        }) {
                            Text("剪切")
                            Image(systemName: "scissors")
                        }
                        Button(action: {
                            if(Clipboard != nil){
                                musicStorage.musicItems[index] = musicStorage.musicItems[Clipboard!]
                                musicStorage.musicItems[Clipboard!] = nil
                                Clipboard = nil
                            }
                            
                        }) {
                            Text("粘贴")
                            Image(systemName: "doc.on.clipboard")
                        }.disabled(Clipboard == nil)
                        Button(action: {
                            if(Clipboard != nil){
                                (musicStorage.musicItems[index],musicStorage.musicItems[Clipboard!]) = (musicStorage.musicItems[Clipboard!],musicStorage.musicItems[index])
                                Clipboard = nil
                            }
                        }) {
                            Text("交换位置")
                            Image(systemName: "arrow.trianglehead.swap")
                        }.disabled(Clipboard == nil)
                        Divider()
                        Button(action: {
                            musicStorage.clear(at: index)
                        }) {
                            Text("删除音乐")
                            Image(systemName: "trash")
                        }.disabled(musicStorage.musicItems[index] == nil)
                    }
                    
                }
                .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType.audio], allowsMultipleSelection: true) { result in
                    do {
                        let urls = try result.get()
                        musicStorage.addMusicItems(from: fileAddIndex, urls: urls)
                    } catch {
                        print("文件选择错误: \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 800)
        .sheet(isPresented: $musicStorage.isEditMusicItem, onDismiss: {
            musicStorage.save()
        }) {
            MusicItemSetting()
            
        }
    }
    
    func handleMusicTap(at index: Int) {
        guard musicStorage.musicItems[index] != nil else {
            return
        }
        if (musicPlayer.currentPlayMusic == musicStorage.musicItems[index]!){
            musicPlayer.play()
        }else{
            musicPlayer.load(musicItem: musicStorage.musicItems[index]!)
            if(config.instantPlay){
                musicPlayer.play()
            }
        }
        
    }
    
    func timeString(from seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MusicPanel()
        .environmentObject(MusicItemStorageFactory.shared)
        .environmentObject(MusicPlayer())
        .environmentObject(Config.shared)
}
