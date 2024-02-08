//
//  SUMenuIcon.swift
//  Idle
//
//  Created by Ki MNO on 2024/2/8.
//

import SwiftUI

@available(macOS 13.0, *)
class SUMenuIconModel: ObservableObject {
    
    @Published var currentTime: String = ""
    
    init(currentTime: String) {
        withAnimation(.linear(duration: 0.3)) {
            self.currentTime = currentTime
        }
        
    }
    
}

@available(macOS 13.0, *)
struct SUMenuIcon: View {
    
    @ObservedObject var model: SUMenuIconModel
    
    var body: some View {
        HStack {
            Image("forest_title_bar")
                .resizable().frame(width: 18,height: 18)
            Text("\(model.currentTime)")
                .contentTransition(.numericText())
                .frame(width: 42)
                .font(.system(.callout, design: .rounded, weight: .medium))
                .offset(y: -0.5)
        }.animation(.default).lineSpacing(0)
    }
    

}

@available(macOS 13.0, *)
#Preview {

    SUMenuIcon(model: SUMenuIconModel(currentTime: "120:00"))
    
}
