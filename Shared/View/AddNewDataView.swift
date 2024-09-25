//
//  AddNewDataView.swift
//  Medically
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI

struct AddNewDataView: View {
    @ObservedObject var modelData: ModelData
    @Environment(\.managedObjectContext) var context
    
    @State var effect = false
    
    @State var pickerTipo = false
    @State var pickerFrecuencia = false
    
    @State var stringPicker = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    TextField("Medicamento", text: $modelData.medicamento)
                        .modifier(InnerShadowModifier())
                        .padding()
                        
                    VStack {
                        HStack {
                            Text("Tipo")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(modelData.pickerTipo[modelData.selectionIndexTipo])
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pickerTipo = true
                            pickerFrecuencia = false
                        }
                        if pickerTipo == true {
                            Picker(selection: $modelData.selectionIndexTipo, label: Text("Tipo"), content: {
                                ForEach(0 ..< modelData.pickerTipo.count) {
                                    Text(self.modelData.pickerTipo[$0])
                                }
                            })
                            .frame(height: 100)
                            .clipped()
                        }
                    }
                    .modifier(InnerShadowModifier())
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Fecuencia")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(modelData.pickerFrecuencia[modelData.selectionIndexFrecuencia])
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pickerFrecuencia = true
                            pickerTipo = false
                        }
                        if pickerFrecuencia == true {
                            Picker(selection: $modelData.selectionIndexFrecuencia, label: Text("Frecuencia"), content: {
                                ForEach(0 ..< modelData.pickerFrecuencia.count) {
                                    Text(self.modelData.pickerFrecuencia[$0])
                                }
                            })
                            .frame(height: 100)
                            .clipped()
                        }
                    }
                    .modifier(InnerShadowModifier())
                    .padding()
                    
                    DatePicker("Hora", selection: $modelData.horaMD, displayedComponents: .hourAndMinute)
                        .modifier(InnerShadowModifier())
                        .padding()
                    
                    VStack {
                        // Si no hay ninguna imagen seleccionada, no se muestra nada, pero si hay una imagen seleccionada, entonces mostramos la imagen
                        if modelData.image.count != 0 {
                            Image(uiImage: UIImage(data: modelData.image)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 280, height: 180)
                                .clipped()

                        }
                        Button(action: {
                            modelData.showGallery = true
                            pickerTipo = false
                            pickerFrecuencia = false
                        }, label: {
                            Text("Selcciona una imagen")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        })
                    }
                    .modifier(InnerShadowModifier())
                    .padding()
                    
                    VStack {
                        Button(action: {
                            modelData.saveData(context: context)
                            modelData.addNewDataView = false
                            effect = true
                        }, label: {
                            Text("Guardar")
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color("ButtonTextColor"))
                                .frame(maxWidth: 350, maxHeight: 100)
                        })
                        .disabled(modelData.medicamento == "")
                        .background(
                            Group {
                                if effect == true {
                                    Rectangle()
                                        .fill(Color("Background"))
                                        .cornerRadius(25)
                                        .shadow(color: Color("LightShadow"), radius: 20, x: 8, y: 8)
                                        .shadow(color: Color("DarkShadow"), radius: 20, x: -8, y: -8)
                                        .blur(radius: 2)
                                } else {
                                    Rectangle()
                                        .fill(Color("Background"))
                                        .cornerRadius(25)
                                        .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                        .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                }
                            }
                        )
                        .frame(width: 350, height: 100)
                    }
                    .padding()
                }
            }
            .onTapGesture(perform: {
                pickerTipo = false
                pickerFrecuencia = false
            })
            .navigationTitle("Agregar")
            .navigationBarItems(trailing: Button(action: {
                modelData.addNewDataView = false
                modelData.medicamento = ""
                modelData.selectionIndexFrecuencia = 0
                modelData.selectionIndexTipo = 0
                modelData.image = Data()
                modelData.horaMD = Date()
            }, label: {
                Text("Cancelar")
                    .foregroundColor(Color("ButtonTextColor"))
            }))
            .sheet(isPresented: $modelData.showGallery, content: {
                ImagePicker(show: $modelData.showGallery, image: $modelData.image)
            })
        }
    }
}

struct InnerShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color("Background"), lineWidth: 4)
                    .shadow(color: Color("DarkShadow"), radius: 2, x: 2, y: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: Color("LightShadow"), radius: 2, x: -2, y: -2)
                    .clipShape(RoundedRectangle(cornerRadius: 6)))
        
    }
}

struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("Background"))
            .cornerRadius(6)
            .shadow(color: Color("DarkShadow"), radius: 3, x: 2, y: 2)
            .shadow(color: Color("LightShadow"), radius: 3, x: -2, y: -2)
    }
}


struct AddNewDataView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewDataView(modelData: .init())
            .previewDevice("iPhone 12")
    }
}
