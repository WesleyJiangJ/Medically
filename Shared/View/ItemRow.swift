//
//  ItemRow.swift
//  Medically
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI
import CoreData

struct ItemRow: View {
    @ObservedObject var myItem: Items
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack() {
            Text("\(myItem.medicina ?? "Empty")")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(Color("ButtonTextColor"))
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(
            Rectangle()
                .fill(Color("Background"))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, maxHeight: 150) //350
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
        )
    }
}

struct ItemRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let item = Items(context: moc)
        item.medicina = "Test Medicina"
        item.pickerTipo = "Test Tipo"
        item.pickerFrecuencia = "Test Frecuencia"
        
        return NavigationView {
            ItemRow(myItem: item)
        }
    }
}
