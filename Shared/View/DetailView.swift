//
//  DetailView.swift
//  Medically
//
//  Created by Wesley Jiang on 8/2/21.
//

import SwiftUI
import CoreData

struct DetailView: View {
    @StateObject var modelData = ModelData()
    @Environment(\.managedObjectContext) var context
    @ObservedObject var myItem: Items
    @State var isEdit = false
    @State var pickerTipo = false
    @State var pickerFrecuencia = false
    @State var effect = false
    
    // Variables que ocupo para las imagenes
    @State var image : Data = .init()
    
    // Al eliminar los datos, desaparece la vista
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                if isEdit != true {
                    HStack {
                        Text("Medicina")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(myItem.medicina ?? "Empty")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShadowModifier())
                    .padding()
                    

                    HStack {
                        Text("Tipo")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(myItem.pickerTipo ?? "Empty")")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShadowModifier())
                    .padding()
                    
                    HStack {
                        Text("Frecuencia")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(myItem.pickerFrecuencia ?? "Empty")")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShadowModifier())
                    .padding()
                    
                    HStack {
                        Text("Toma")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(myItem.horaString ?? "Empty")")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShadowModifier())
                    .padding()
                    
                    Toggle(isOn: $myItem.notificationState) {
                        Text("Notificación")
                    }
                    .onChange(of: myItem.notificationState, perform: { value in
                        modelData.notificationStateFunc(item: myItem, context: context)
                    })
                    .modifier(ShadowModifier())
                    .padding()
                    
                    // Muestro la imagen almacenada
                    HStack {
                        // Si no se guardo una imagen, entonces no mostrar nada, pero si hay una iamgen, mostrarla
                            if myItem.image != nil {
                                Image(uiImage: UIImage(data: myItem.image ?? self.image)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 280, height: 180)
                                    .clipped()
                                    .modifier(ShadowModifier())
                                    .padding()
                            }
                    }
                    
                    VStack {
                        Button(action: {
                            modelData.sumaHora(item: myItem, context: context)
                            effect = true
                        }, label: {
                            Text("Completado")
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color("ButtonTextColor"))
                                .frame(maxWidth: 350, maxHeight: 100)
                        })
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
                else {
                    HStack {
                        Text("Medicina")
                        TextField("\(myItem.medicina ?? "Empty")", text: $modelData.medicamento)
                            .multilineTextAlignment(.trailing)
                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(InnerShadowModifier())
                    .padding()

                    VStack {
                        HStack {
                            Text("Tipo")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(modelData.pickerTipo[modelData.indexTipoDV])
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pickerTipo = true
                            pickerFrecuencia = false
                        }
                        if pickerTipo == true {
                            // Segundo - ponemos el indexTipoDV (DetailView) en "Selection"
                            Picker(selection: $modelData.indexTipoDV, label: Text("Tipo"), content: {
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
                            Text("Frecuencia")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(modelData.pickerFrecuencia[modelData.indexFrecuenciaDV])
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pickerFrecuencia = true
                            pickerTipo = false
                        }
                        if pickerFrecuencia == true {
                            // Segundo - ponemos el indexFrecuenciaDV (DetailView) en "Selection"
                            Picker(selection: $modelData.indexFrecuenciaDV, label: Text("Frecuencia"), content: {
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
                    
                    // Segundo - ponemos el horaDV (DetailView) en "Selection"
                    DatePicker("Hora", selection: $modelData.horaDV, displayedComponents: .hourAndMinute)
                        .modifier(InnerShadowModifier())
                        .padding()
                    
                    VStack {
                        // Verifico si hay una imagen seleccionada, si no la hay no muestro nada, pero si hay una, la muestro (Este se muestra luego de editar la foto)
                        if modelData.imageDV.count != 0 {
                                Image(uiImage: UIImage(data: modelData.imageDV)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 280, height: 180)
                                    .clipped()
                            }
                            // Verifico si hay una imagen en Core Data, si la hay entonces la muestro (Este se muestra primero, al abrir el Detail)
                            // "modelData.imageDV.count == 0" es para confirmar si hay una imagen seleccionada, si no la hay entonces no se muestra este Image()
                            if myItem.image != nil && modelData.imageDV.count == 0 {
                                Image(uiImage: UIImage(data: myItem.image ?? self.image)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 280, height: 180)
                                    .clipped()
                            }
                        
                        Button(action: {
                            modelData.showGallery = true
                        }, label: {
                            Text(myItem.image != nil ? "Cambiar imagen" : "Seleccionar imagen")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        })
                        // Llamamos al picker Gallery
                        .sheet(isPresented: $modelData.showGallery, content: {
                            ImagePicker(show: $modelData.showGallery, image: $modelData.imageDV)
                        })
                    }
                    .modifier(InnerShadowModifier())
                    .padding()
                }
                
                if isEdit == true {
                    HStack {
                        Button(action: {
                            if modelData.medicamento.isEmpty {
                                modelData.medicamento = myItem.medicina ?? "Empty"
                            }
                            
                            // Verifica que imagenDV no esté vacia, y si no está vacia entonces asigna la imagen seleccionada en imageDV a imageD de Core Data
                            if modelData.imageDV.count != 0 {
                                myItem.image = modelData.imageDV
                            }
                            
                            // Verifica si imageDV está vacío y si en Core Data hay una imagen almacenada, si es así entonces asigna la imagen almacenada en imagenDV para mostrarla
                            if modelData.imageDV.count == 0 && myItem.image != nil{
                                modelData.imageDV = myItem.image!
                            }
                            
                            modelData.editData(item: myItem, context: context)
                            isEdit = false
                            
                        }, label: {
                            Text("Actualizar")
                                .foregroundColor(Color("ButtonTextColor"))
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: 100) //350
                                .background(
                                    Rectangle()
                                        .fill(Color("Background"))
                                        .cornerRadius(10)
                                        .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                        .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                )
                        })
                        
                        Button(action: {
    //                        modelData.deleteNotification(item: myItem)
                            self.presentationMode.wrappedValue.dismiss()
                            context.delete(myItem)
                            try! context.save()
                            
                        }, label: {
                            Image(systemName: "trash")
                                .accentColor(.red)
                                .frame(maxWidth: 110, maxHeight: 100) //350
                                .background(
                                    Rectangle()
                                        .fill(Color("Background"))
                                        .cornerRadius(10)
                                        .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                        .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                )
                        })
                    }
                    .frame(width: 400, height: 100)
                    .padding()
                }
            }
        }
        .onTapGesture(perform: {
            pickerTipo = false
            pickerFrecuencia = false
        })
        .navigationBarTitle(isEdit == false ? "Detalles" : "Editar", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            if isEdit == false {
                isEdit = true
                // Primero - Al editar asigno a indexTipoDV (DetailView) el valor de indexTipo
                modelData.indexTipoDV = Int(myItem.indexTipo)

                // Primero - Al editar asigno a indexFrecuenciaDV (DetailView) el valor de indexFrecuencia
                modelData.indexFrecuenciaDV = Int(myItem.indexFrecuencia)

                // Primero - Asignamos a horaDV (DetailView) el valor de hours (Core Data)
                modelData.horaDV = myItem.hora!

                // Limpiamos la imagenDV
                modelData.imageDV = modelData.limpio
            }
            else {
                isEdit = false
            }
        }, label: {
            Text(isEdit == false ? "Editar" : "Cancelar")
                .foregroundColor(Color("ButtonTextColor"))
        }))
    }
}

struct DetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let item = Items(context: moc)
        item.medicina = "Test Medicina"
        item.pickerTipo = "Test Tipo Picker"
        item.pickerFrecuencia = "Test Frecuencia Picker"
        item.horaString = "Test Hora"
        
        return NavigationView {
            DetailView(myItem: item)
        }
    }
}
