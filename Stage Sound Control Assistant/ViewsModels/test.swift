import SwiftUI

struct TestView: View {
    @State private var showModal = false

       var body: some View {
           ZStack {
               // 背景内容
               Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)

               // 可点击的 View
               RoundedRectangle(cornerRadius: 20)
                   .fill(Color.blue)
                   .frame(width: 100, height: 100)
                   .onTapGesture {
                       withAnimation(.easeInOut(duration: 0.3)) {
                           showModal.toggle()
                       }
                   }
                   .scaleEffect(showModal ? 3.0 : 1.0) // 放大效果
                   .opacity(showModal ? 1 : 0.9) // 轻微透明度过渡
                   .zIndex(1) // 置于顶层
                   .offset(x:10,y:10)

               // 模态内容
               if showModal {
                   RoundedRectangle(cornerRadius: 20)
                       .fill(Color.white)
                       .frame(width: 300, height: 300)
                       .overlay(
                           VStack {
                               Text("模态框内容")
                                   .font(.headline)
                               Button("关闭") {
                                   withAnimation(.easeInOut(duration: 0.3)) {
                                       showModal = false
                                   }
                               }
                           }
                       )
                       .zIndex(2)
                       .transition(.opacity) // 透明度过渡动画
               }
           }
       }
}

#Preview {
    TestView()
}
