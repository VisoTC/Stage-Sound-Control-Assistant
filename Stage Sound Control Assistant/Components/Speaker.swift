//
//  Speaker.swift
//  Stage Sound Control Assistant
//
//  Created by VisoTC liu on 2024/11/12.
//

import SwiftUI

struct SpeakerImage: View {
    @Binding var volume:Int
    
    var body: some View{
        Image(systemName: volume == 0 ? "speaker.slash.fill"
              :(volume <= 25 ? "speaker.fill"
              :(volume <= 50 ? "speaker.1.fill"
                : (volume <= 75 ? "speaker.2.fill"
                   :"speaker.3.fill")))
        )
    }
}

#Preview {
    SpeakerImage(volume: Binding(get: {
        return 90
    }, set: {
        _ = $0
    }))
}
