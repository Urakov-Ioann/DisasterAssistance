//
//  FirebaseRepository.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 22.04.2024.
//

import Foundation

struct DisasterModel: Codable {
    let location: Location
    let numberOfVictims: String
    let typeOfDisaster: String
    let typeOfInjures: String
}

protocol FirebaseRepositoryProtocol {
    func setLocation(
        documentName: String,
        locModel: DisasterModel,
        completion: @escaping (Result<Bool, Error>) -> Void)
    func updateLocation(
        documentName: String,
        locModel: DisasterModel,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    func getAllLocations(completion: @escaping (Result<[DisasterModel]?, Error>) -> Void)
}

class FirebaseRepository: FirebaseRepositoryProtocol {
    var locModel: DisasterModel?
    let firebaseService: FirebaseServiceProtocol
    
    init(locModel: DisasterModel? = nil,
         firebaseService: FirebaseServiceProtocol) {
        self.locModel = locModel
        self.firebaseService = firebaseService
    }
    
    func setLocation(
        documentName: String,
        locModel: DisasterModel,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        firebaseService.setLocation(
            documentName: documentName,
            locModel: locModel
        ) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateLocation(
        documentName: String,
        locModel: DisasterModel,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        firebaseService.updateLocation(
            documentName: documentName,
            locModel: locModel
        ) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllLocations(completion: @escaping (Result<[DisasterModel]?, Error>) -> Void) {
        firebaseService.getAllLocations { result in
            switch result {
            case .success(let loc):
                guard let loc = loc else {
                    completion(.success(nil))
                    return
                }
                var allLocModel: [DisasterModel] = []
                let decoder = JSONDecoder()
                for element in loc {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: element.data(),
                                                                  options: JSONSerialization.WritingOptions.prettyPrinted)
                        let model = try decoder.decode(DisasterModel.self,
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

