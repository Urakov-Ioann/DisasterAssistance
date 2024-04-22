//
//  FirebaseService.swift
//  spravochnik_spz
//
//  Created by Иоанн Ураков on 22.04.2024.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

protocol FirebaseServiceProtocol {
    func setLocation(
        locModel: Location,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func getAllLocations(completion: @escaping (Result<[QueryDocumentSnapshot]?, Error>) -> Void)
}

final class FirebaseService {
    var uid: String?
    static let shared = FirebaseService()
    func configureFB() -> Firestore {
        var database: Firestore
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        database = Firestore.firestore()
        return database
    }
}

extension FirebaseService: FirebaseServiceProtocol {
    
    func setLocation(
        locModel: Location,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let db = configureFB()
        let locRef = db.collection("Locations").document(UUID().uuidString)
//        locRef.setData(locModel) { error in
//            if let error = error {
//                print("FirebaseService setLocation: Error writing document: \(error)")
//                completion(.failure(error))
//            } else {
//                print("FirebaseService setLocation: Document successfully written!")
//                completion(.success(""))
//            }
//        }
        do {
            try locRef.setData(from: locModel) { error in
                if let error = error {
                    print("FirebaseService setLocation: Error writing document: \(error)")
                    completion(.failure(error))
                } else {
                    print("FirebaseService setLocation: Document successfully written!")
                    completion(.success(true))
                }
            }
        } catch let error {
            print("FirebaseService setLocation: Error writing to Firestore: \(error)")
            completion(.failure(error))
        }
    }
    
    func getAllLocations(completion: @escaping (Result<[QueryDocumentSnapshot]?, Error>) -> Void) {
        let db = configureFB()
        let locRef = db.collection("Locations")
        locRef.getDocuments() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("ERROR getAllLocations querySnapshot")
                completion(.success(nil))
                return
            }
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                completion(.success(querySnapshot.documents))
            }
        }
    }
}
