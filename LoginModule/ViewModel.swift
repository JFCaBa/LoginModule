//
//  ViewModel.swift
//  LoginModule
//
//  Created by Jose on 16/12/2022.
//

import Foundation
import Combine

final class ViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var password = ""
    
    @Published var hasError = false
    @Published var isSigningIn = false
    
    @Published private var signingResponse: SignInResponse!
    
    var signingResponsePublisher: AnyPublisher<String?, Never> {
        $signingResponse
            .map{$0?.mensaje}
            .eraseToAnyPublisher()
    }
    
    var isSigningInPublisher: AnyPublisher<Bool, Never> {
        $isSigningIn
            .eraseToAnyPublisher()
    }
    
    var canSignIn: Bool {
        return !username.isEmpty && !password.isEmpty
    }
    
    // MARK: API
    func signIn() {
        guard canSignIn else { return }
        isSigningIn = true
        
        // Create the request
        let url = "https://sincomfas.hopto.org/api/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")
        
        let parameters = ["email":username, "password":password]
        let jsonAsData = try? JSONSerialization.data(withJSONObject: parameters, options : .prettyPrinted)
        request.httpBody = jsonAsData
        
        // Launch the connection
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil || (response as! HTTPURLResponse).statusCode != 200 {
                    self?.hasError = true
                }
                else if let data = data {
                    do {
                        self?.signingResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                    }
                    catch {
                        self?.hasError = true
                    }
                }
                self?.isSigningIn = false
            }
        }.resume()
    }
}

// MARK: - Model
fileprivate struct SignInResponse: Decodable {

    // MARK: - Properties
    let userId: Int
    let email: String
    let mensaje: String?
    let token: String
}
