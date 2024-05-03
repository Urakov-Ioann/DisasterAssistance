//
//  AuthService.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 03.05.2024.
//

import UIKit
import FirebaseAuth

struct LoginUserRequest {
    let email: String
    let password: String
}


protocol AuthServiceProtocol {
    func loginUser(
        with userRequest: LoginUserRequest,
        completion: @escaping (Error?) -> Void
    )
    func logout(
        completion: @escaping (Error?) -> Void
    )
}

final class AuthService: AuthServiceProtocol {
    func logout(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    func loginUser(with userRequest: LoginUserRequest, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(
            withEmail: userRequest.email,
            password: userRequest.password
        ) { result, error in
            if let error = error {
                completion(error)
                return
            } else {
                completion(nil)
            }
        }
    }
}
