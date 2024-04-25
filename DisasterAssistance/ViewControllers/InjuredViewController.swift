//
//  InjuredViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class InjuredViewController: UIViewController {

    private let firestoreRepository: FirebaseRepositoryProtocol = FirebaseRepository(firebaseService: FirebaseService() as FirebaseServiceProtocol)
    private let locationService: LocationServiceProtocol = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Injured"
    }
    
    @IBAction func reportButtonAction(_ sender: Any) {
        guard let cllocation = locationService.getCurrentLocation() else { return }
        let location = Location(latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude)
        
//        for _ in 0...20 {
//            let location = Location(latitude: Double.random(in: 45.06...46), longitude: Double.random(in: 39...41))
//            self.sendLocation(locModel: location)
//        }
        
        self.sendLocation(locModel: location)
    }
    
    private func sendLocation(locModel: Location) {
        firestoreRepository.setLocation(locModel: locModel) { result in
            switch result {
            case .success:
                self.showAlert(title: "Успешно", message: "Ваша геопозиция отправлена службам спасения")
            case .failure:
                self.showAlert(title: "Ошибка", message: "Ваша геопозиция не отправлена, попробуйте снова")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
