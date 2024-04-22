//
//  FirebaseRepository.swift
//  spravochnik_spz
//
//  Created by Иоанн Ураков on 22.04.2024.
//

import Foundation

protocol FirebaseRepositoryProtocol {
    func setLocation(locModel: Location,
                        completion: @escaping (Result<Bool, Error>) -> Void)
    func getAllLocations(completion: @escaping (Result<[Location]?, Error>) -> Void)
}

class FirebaseRepository: FirebaseRepositoryProtocol {
    var locModel: Location?
    let firebaseService: FirebaseServiceProtocol
    
    init(locModel: Location? = nil,
         firebaseService: FirebaseServiceProtocol) {
        self.locModel = locModel
        self.firebaseService = firebaseService
    }
    
    func setLocation(
        locModel: Location,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        firebaseService.setLocation(locModel: locModel) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllLocations(completion: @escaping (Result<[Location]?, Error>) -> Void) {
        firebaseService.getAllLocations { result in
            switch result {
            case .success(let loc):
                guard let loc = loc else {
                    completion(.success(nil))
                    return
                }
                var allLocModel: [Location] = []
                let decoder = JSONDecoder()
                for element in loc {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: element.data(),
                                                                  options: JSONSerialization.WritingOptions.prettyPrinted)
                        let model = try decoder.decode(Location.self,
                                                       from: jsonData)
                        allLocModel.append(model)
                    } catch {
                        print("Error", error)
                    }
                }
                completion(.success(allLocModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

