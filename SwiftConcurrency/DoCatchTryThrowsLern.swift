//
//  DoCatchTryThrowsLern.swift
//  SwiftConcurrency
//
//  Created by Jaya Sabeen on 29/01/25.
//

import SwiftUI

class DoTryCatchDataManager {
    
    let isActive: Bool = true
    
    func getTitile() -> (titel: String?, error: Error?) {
        return isActive ? ("New Title .. !", nil) : (nil, URLError(.badURL))
    }
    
    func getTitleAnother() -> Result<String, Error> {
        return isActive ? .success("New Sucess method .. !") : .failure(URLError(.appTransportSecurityRequiresSecureConnection))
    }
    
    func returnUsingTry() throws -> String {
//        if isActive {
//            return "Old Title .. !"
//        } else {
            throw URLError(.badServerResponse)
//        }
    }
    
    func finalTitle() throws -> String {
        if isActive {
            return "Final Title .. !"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoTryCatchVM: ObservableObject {
    @Published var text: String = "Starting Text.. !"
    let manager = DoTryCatchDataManager()
    
    func fetchTitle() {
        /*let returnedValue = manager.getTitile()
        if let newTitle = returnedValue.titel {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = "\(error)"
        } else {
            self.text = "Error"
        }*/
        
        /*let result = manager.getTitleAnother()
        switch result {
        case .success(let success):
            self.text = success
        case .failure(let failure):
            self.text = failure.localizedDescription
//        default:
//            self.text = "Default"
        }*/
        
//        let optionalTitle = try? manager.returnUsingTry()
//        if let optionalTry = optionalTitle {
//            self.text = optionalTry
//        }
        
        do {
            let optionalTitle = try? manager.returnUsingTry()
            if let optionalTry = optionalTitle {
                self.text = optionalTry
            }
            
            let finalTitle = try manager.finalTitle()
            self.text = finalTitle
        } catch let eror {
            self.text = eror.localizedDescription
        }
        
    }
}

struct DoCatchTryThrowsLern: View {
    
    @StateObject private var VM = DoTryCatchVM()
    
    var body: some View {
        Text(VM.text)
            .frame(width: 300, height: 300)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .font(.title)
            .cornerRadius(50.0)
            .onTapGesture {
                VM.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsLern()
}
