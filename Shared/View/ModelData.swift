//
//  ModelData.swift
//  Medically
//
//  Created by Wesley Jiang on 8/2/21.
//

import Foundation
import CoreData
import UserNotifications

class ModelData: ObservableObject {
    // Partida de actualización del almacenamiento
    @Published var updateItem : Items!
    
    @Published var medicamento = ""
    @Published var addNewDataView = false
    @Published var notificationState = true
    
    // Picker de Tipo
    @Published var pickerTipo = ["Pastillas", "Jarabe", "Polvos", "Supositorio", "Gotas", "Inyección", "Efervescente"]
    @Published var selectionIndexTipo = 0
    
    // Declaro un index en cero
    @Published var indexFrecuenciaDV = 0
    @Published var indexTipoDV = 0
    
    // Picker Horas
    @Published var pickerFrecuencia = ["Cada 2 horas", "Cada 4 horas", "Cada 6 horas", "Cada 8 horas", "Cada 12 horas", "Diario", "Cada hora"]
    var frecuenciaIntPicker =      [       12,            6,              4,              3,              2,             1,        24     ]
    var horasSumadas =      [       2,             4,              6,              8,              12,            24,       1      ]
    var horasSumadasVar = 0
    @Published var selectionIndexFrecuencia = 0
    
    // Variable que guarda el valor al agregarlo a Core Data
    @Published var horaMD = Date()
    
    // Variable que almacena el valor que tenía en Core Data para mostrarlo en DetailView y a la vez almacenará el valor nuevo al editarse
    @Published var horaDV = Date()
    
    // Variables que utilizaremos pora convertir la hora (Date()) en String
    var formatter = DateFormatter()
    var dateString = ""
    
    // Variables para almacenar la imagen
    @Published var image: Data = .init()
    
    @Published var imageDV: Data = .init()
    @Published var limpio: Data = .init()
    @Published var showGallery = false
    
    func saveData(context: NSManagedObjectContext) {
        let itemEntity = NSEntityDescription.entity(forEntityName: "Items", in: context)
        let item = Items(entity: itemEntity!, insertInto: context)
        
        // Guardamos el nombre
        item.medicina = medicamento
        // Guardamos el tipo y su index
        item.pickerTipo = pickerTipo[selectionIndexTipo]
        item.indexTipo = Int16(selectionIndexTipo)
        // Guardamos la frecuencia y su index
        item.pickerFrecuencia = pickerFrecuencia[selectionIndexFrecuencia]
        item.indexFrecuencia = Int16(selectionIndexFrecuencia)
        
        // Almaceno la cantidad de horas en dependencia de la frecuencia
        item.frecuenciaIntPicker = Int16(frecuenciaIntPicker[selectionIndexFrecuencia])
        // Almacenamos las horas sumadas al Core Data
        item.horasSumadas = Int16(horasSumadas[selectionIndexFrecuencia])

        // Almacenamos la hora del DatePicker
        item.hora = horaMD
        
        // Convertimos la variable horaMD en String y solo obtenemos la hora
        formatter.timeStyle = .short
        dateString = formatter.string(from: horaMD)
        // Almacenamos la hora String en Core Data
        item.horaString = dateString
        
        // Almacenamos en true las notificaciones
        item.notificationState = true
        
        // Llamamos a la funcion para crear la notificación
        createNotification(item: item)
        
        // Verificamos si la imagen no esta vacia, si no esta vacia entonces almacenamos la image en Core Data
        if image.count != 0 {
            item.image = image
        }
        // Pero si no hay ninguna imagen seleccionada, entonces almacenamos "nil" en Core Data
        else {
            item.image = nil
        }
        
        
        // Guardar en disco.
        do {
            try context.save()
            addNewDataView = false
        } catch let error as NSError {
            print("Error al insertar: \(error)")
        }
    }
    
    func editData(item: Items, context: NSManagedObjectContext) {
        deleteNotification(item: item)
        
        // Actualizar valores
        updateItem = item
        // Validamos que los valores que vamos a editar no esten vacios
        if updateItem != nil && medicamento != "" {
            updateItem.medicina = medicamento
            
            // Actualizamos el valor de indexTipo (Core Data) con el valor que nos da indexTipoDV (DetailVIew)
            updateItem.indexTipo = Int16(indexTipoDV)
            // Actualizamos la posición del valor del picker con el valor que tenemos de indexTipoDV
            updateItem.pickerTipo = pickerTipo[indexTipoDV]
            
            // Actualizamos el valor de indexFrecuencia (Core Data) con el valor que nos da indexFrecuenciaDV (DetailVIew)
            updateItem.indexFrecuencia = Int16(indexFrecuenciaDV)
            // Actualizamos la posición del valor del picker con el valor que tenemos de indexFrecuenciaDV //
            updateItem.pickerFrecuencia = pickerFrecuencia[indexFrecuenciaDV]                                           // Aca tenemos que actualizarlos
                                                                                                 // a la vez...
            // Actualizamos la cantidad de horas en dependencia de la frecuencia                 // Picker de frecuencia (String) con frecuencia (Int) con la hora sumada
            updateItem.frecuenciaIntPicker = Int16(frecuenciaIntPicker[indexFrecuenciaDV])                              //
            horasSumadasVar = horasSumadas[indexFrecuenciaDV]                                              //
            updateItem.horasSumadas = Int16(horasSumadasVar)
            
            // Actualizamos la hora
            updateItem.hora = horaDV
            
            // Actualizamos la hora String
            formatter.timeStyle = .short
            dateString = formatter.string(from: horaDV)
            
            // Almacenamos la hora String
            updateItem.horaString = dateString
            
            // Verificamos si imagenDV esta vacia, si esta vacia entonces almacenamos en imageD nil
            if imageDV.count == 0 {
                updateItem.image = nil
    //            print("ImageDV == 0")
            }
            // Pero si hay una imagen en imageDV entonces lo almacenamos en Core Data
            else {
                updateItem.image = imageDV
    //            print("Asigno imageDV a ImageD")
            }
            
            // Actualizamos la notificacion
            if item.notificationState == true {
                modifyNotification(item: item)
//                print("Edita")
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Error al modificar: \(error)")
            }
        }
    }
    
    func createNotification(item: Items) {
        // Separamos la hora y el minuto en constantes
        let componentHour = Calendar.current.dateComponents([.hour], from: item.hora!)
        let componentMinute = Calendar.current.dateComponents([.minute], from: item.hora!)
        let hora = componentHour.hour!
        let minuto = componentMinute.minute!
        
        // Creamos la notificación
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.subtitle = item.medicina ?? ""
        content.sound = UNNotificationSound.default
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = hora
        dateComponents.minute = minuto
        
//        print("Hora nueva: " + "\(dateComponents.hour)")
//        print("Minuto nuevo: " + "\(dateComponents.minute)")
        
        for i in 0..<(item.frecuenciaIntPicker) {
            // Mostramos la notificacion dependiendo del tiempo en el que establezca
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // Elegimos los identificadores
            let request = UNNotificationRequest(identifier: "\(item.medicina ?? "")" + "\(item.pickerTipo ?? "")" + "_\(i)", content: content, trigger: trigger)
//            print("Este es el request" + "\(request)")
            
            // add our notification request
            UNUserNotificationCenter.current().add(request)
            
//            print("\(i+1). " + "La hora sumada es: " + "\(dateComponents.minute)")
            // Verificamos que la hora sea menor o mayor a 23
            if dateComponents.hour! <= 23 {
                // Sumamos la hora que tenemos a la hora que se le va a sumar
                dateComponents.hour! += Int(item.horasSumadas)
                
                /* Verificamos que dateComponents.hour no sea mayor a 24, y si es mayor a 24 le resto 24:
                Ejemplo:
                 dateComponent.hour (29) >= 24
                 var horaReiniciada (0) = dateComponent.hour (29) - 24  / A horaReiniciada se le asignaría 5
                 dateComponents.hour = 0 + horaReiniciada (5) / Ahora dateComponent.hour vale 5 */
                if dateComponents.hour! >= 24 {
                    let horaReiniciada = dateComponents.hour! - 24
                    dateComponents.hour = 0 + horaReiniciada
                }
            }
        }
    }
    
    func modifyNotification(item: Items) {
        // Separamos la hora y el minuto en constantes
        let componentHour = Calendar.current.dateComponents([.hour], from: horaDV)
        let componentMinute = Calendar.current.dateComponents([.minute], from: horaDV)
        let hora = componentHour.hour!
        let minuto = componentMinute.minute!
        
        // Modificamos la notificación
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.subtitle = item.medicina ?? ""
        content.sound = UNNotificationSound.default
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = hora
        dateComponents.minute = minuto
        
        for i in 0..<(item.frecuenciaIntPicker) {
            // Mostramos la notificacion dependiendo del tiempo en el que establezca
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // Elegimos los identificadores
            let request = UNNotificationRequest(identifier: "\(item.medicina ?? "")" + "\(item.pickerTipo ?? "")" + "_\(i)", content: content, trigger: trigger)
            
            // add our notification request
            UNUserNotificationCenter.current().add(request)
            
            // Verificamos que la hora sea menor o mayor a 23
            if dateComponents.hour! <= 23 {
                // Sumamos la hora que tenemos a la hora que se le va a sumar
                dateComponents.hour! += Int(item.horasSumadas)
//                print(horasSumadasVar)
                
                /* Verificamos que dateComponents.hour no sea mayor a 24, y si es mayor a 24 le resto 24:
                Ejemplo:
                 dateComponent.hour (29) >= 24
                 var horaReiniciada (0) = dateComponent.hour (29) - 24  / A horaReiniciada se le asignaría 5
                 dateComponents.hour = 0 + horaReiniciada (5) / Ahora dateComponent.hour vale 5 */
                if dateComponents.hour! >= 24 {
                    let horaReiniciada = dateComponents.hour! - 24
                    dateComponents.hour = 0 + horaReiniciada
                }
            }
        }
    }
    
    // Segundo - Eliminamos las notificaciones elegidas
    func deleteNotification(item: Items) {
        updateItem = item
        let identifier = updateItem.medicina! + updateItem.pickerTipo!
//        print(identifier)
        
        for i in 0..<(item.frecuenciaIntPicker) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier + "_\(i)"])
        }
    }
    
    func sumaHora(item: Items, context: NSManagedObjectContext) {
        updateItem = item
        
        let horaSumada = updateItem.hora ?? Date()
        let horaNueva = Calendar.current.date(byAdding: .hour, value: Int(updateItem.horasSumadas), to: horaSumada)
//        print(horaNueva)
        updateItem.hora = horaNueva
        formatter.timeStyle = .short
        dateString = formatter.string(from: horaNueva ?? Date())
//        print(dateString)
        
        updateItem.horaString = dateString
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error al modificar: \(error)")
        }
    }
    
    func notificationStateFunc(item: Items, context: NSManagedObjectContext) {
        updateItem = item
        
        if item.notificationState == false {
            deleteNotification(item: item)
//            print("Desactiva notificaciones")
        }
        else {
            createNotification(item: item)
//            print("Activa notificaciones")
        }
        
        updateItem.notificationState = item.notificationState

        do {
            try context.save()
        } catch let error as NSError {
            print("Error al modificar: \(error)")
        }
        
    }
}

// Para que la notificación salga cuando la app este en primer plano
class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.badge, .banner, .sound])

    }
}
