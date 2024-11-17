//
//  MusicItemSetting.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/10.
//

import SwiftUI

struct MusicItemSetting: View {
    @EnvironmentObject private var musicStorage:MusicStorage
    @State private var isFilePickerPresented = false
    @State private var showFileImporter = false
    @State private var isDroping = false
    @State private var isDropTargeted = false
    @State private var vol = -1
    var body: some View {
        NavigationStack{
            VStack{
                if let editMusicItem = musicStorage.editMusicItem {
                    List {
                        Section(){
                            HStack(){
                                Spacer()
                                VStack(alignment: .center){
                                    Image(systemName: editMusicItem.url != nil  ? "document.fill" : "questionmark.square.dashed")
                                        .padding(.bottom)
                                        .font(.system(size: 50))
                                        .foregroundStyle(.secondary)
                                    Text(editMusicItem.url != nil  ? editMusicItem.url!.lastPathComponent : "文件已丢失")
                                }.padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.secondary.opacity(isDropTargeted ? 0.2 : 0.1)) // 半透明叠层
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10) // 圆角矩形描边
                                            .stroke(style: StrokeStyle(lineWidth:isDropTargeted ? 2 : 0, dash: [5, 5]))
                                            .foregroundStyle(Color.accentColor)
                                    ).onDrop(of: ["public.file-url","public.audio"], isTargeted: $isDropTargeted) { providers in
                                        guard let provider = providers.first else { return false }
                                        if provider.hasItemConformingToTypeIdentifier("public.audio") {
                                            provider.loadItem(forTypeIdentifier:"public.audio" , options: nil) { (item, error) in
                                                if let _url = item as? URL {
                                                    Task{
                                                        await musicStorage.changeFile(musicItem: editMusicItem, url: _url)
                                                    }
                                                }
                                            }
                                            return true
                                        }
                                        return false
                                        
                                    }.onTapGesture{
                                        showFileImporter = true
                                    }
                                Spacer()
                            }
                        }.listRowSeparator(.hidden)
                        Section(header: Text("显示名")) {
                            TextField("歌曲名", text: Binding(
                                get: { editMusicItem.name },
                                set: { editMusicItem.name = $0
                                    editMusicItem.objectWillChange.send()}
                            ))
                        }
                        Section() {
                            HStack {
                                Text("音量: ")
                                Slider(value: Binding(
                                    get: {
                                        DispatchQueue.main.async{
                                            vol = editMusicItem.volume
                                        }
                                        return Float(editMusicItem.volume)
                                    },
                                    set: { editMusicItem.volume = Int($0)}
                                ), in: 0...100)
                                Text(String("\(vol)%"))
                            }
                        }
                        
                        
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                    .navigationTitle("歌曲设置")
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.audio], allowsMultipleSelection: false) { result in
                        do {
                            let urls = try result.get()
                            if urls.first != nil{
                                Task{
                                    await musicStorage.changeFile(musicItem: editMusicItem, url: urls.first!)
                                }
                            }
                            
                        } catch {
                            print("文件选择错误: \(error.localizedDescription)")
                        }
                    }
                    .toolbar{
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                musicStorage.isEditMusicItem = false
                            }) {
                                Text("关闭")
                            }
                        }
                    }
                    
                    
                    
                }else{
                    VStack{
                        Image(systemName: "questionmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                            .padding()
                        Text("没有可以编辑的歌曲设置")
                    }.toolbar{
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                musicStorage.isEditMusicItem = false
                            }) {
                                Text("关闭")
                            }
                        }
                    }
                    
                }
            }.frame(minHeight: 300)
        }
    }
    
    private func durationString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    MusicItemSetting()
        .environmentObject(MusicItemStorageFactory.shared)
}
