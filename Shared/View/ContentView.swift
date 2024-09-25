//
//  ContentView.swift
//  Shared
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var modelData = ModelData()
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Items.entity(), sortDescriptors: [NSSortDescriptor(key: "medicina", ascending: true)]) var result : FetchedResults<Items>
    @StateObject var delegate = NotificationDelegate()
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(result) { resultados in
                            NavigationLink(destination: DetailView(myItem: resultados)) {
                                ItemRow(myItem: resultados)
                            }
                        }
                        .padding()
                        .frame(width: .none, height: 200)
                    }
                }

                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    FloatingButton(modelData: modelData)
                        .padding()
                }
            }
            .navigationTitle("Medically")
//            .onAppear(perform: {
//                UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named:"ButtonTextColor")]
//            })
//            .navigationBarItems(trailing: Button(action: {
//                print(result)
//            }, label: {
//                Text("Ver todo")
//            }))
        }
        .onAppear(perform: {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permiso OK")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
            UNUserNotificationCenter.current().delegate = delegate
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
