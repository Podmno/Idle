//
//  SUMenuIcon.swift
//  Idle
//
//  Created by Ki MNO on 2024/2/8.
//

import SwiftUI

@available(macOS 14.0, *)
class SUMenuIconModel: ObservableObject {
    
    @Published var currentTime: String = ""
    
    init(currentTime: String) {
        withAnimation(.linear(duration: 0.3)) {
            self.currentTime = currentTime
        }
        
    }
    
}

@available(macOS 14.0, *)
struct SUMenuIcon: View {
    
    @ObservedObject var model: SUMenuIconModel
    
    var body: some View {
        HStack {
            Image("forest_title_bar")
                .resizable().frame(width: 18,height: 18)
            Text("\(model.currentTime)")
                .contentTransition(.identity)
                .frame(width: 42,height: 18)
                .offset(y: -0.5)
                
                .font(.system(size: 12))
        }.animation(.linear(duration: 0.1))
    }
    

}

@available(macOS 14.0, *)
#Preview {

    SUMenuIcon(model: SUMenuIconModel(currentTime: "120:00"))
    
}
