//
//  FloatingButton.swift
//  Medically
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI

struct FloatingButton: View {
    @ObservedObject var modelData: ModelData
    
    var body: some View {
        Button(action: {
            modelData.addNewDataView = true
        }, label: {
            Image(systemName: "plus")
                .resizable()
                .padding(25)
                .foregroundColor(Color("ButtonTextColor"))
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(Color("Background"))
                        .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                        .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                )
                .rotationEffect(.degrees(modelData.addNewDataView ? 90 : 0))
                .scaleEffect(modelData.addNewDataView ? 1.2 : 1)
                .animation(.spring())
        })
        .sheet(isPresented: $modelData.addNewDataView, content: {
            AddNewDataView(modelData: modelData)
        })
    }
}

struct FloatingButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloatingButton(modelData: .init())
                .previewLayout(.fixed(width: 100, height: 100))
                .colorScheme(.light)
            
            FloatingButton(modelData: .init())
                .previewLayout(.fixed(width: 100, height: 100))
                .colorScheme(.dark)
        }
            
    }
}
