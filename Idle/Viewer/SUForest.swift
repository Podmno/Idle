//
//  SUForest.swift
//  Idle
//
//  Created by Ki MNO on 2024/2/7.
//

import SwiftUI

struct SUForest: View {
    var body: some View {
        ZStack {
            
            Image("ground-piece").resizable().frame(width: 200,height: 100)
            Image("ground-left").resizable().frame(width: 100,height: 150).offset(x:-50, y:75)
            Image("ground-right").resizable().frame(width: 100,height: 150).offset(x:50, y:75)
            
            
        }.frame(width: 500,height: 500)
        
    }
}

#Preview {
    SUForest()
}
