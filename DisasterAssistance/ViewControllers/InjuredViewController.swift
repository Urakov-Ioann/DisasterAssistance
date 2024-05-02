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
        
//        let locations = [
//            Location(latitude: 55.758938036209614, longitude: 37.643678622386545), // Moscow
//            Location(latitude: 55.82251901906957, longitude: 37.612010524127555), // Moscow
//            Location(latitude: 55.77714130014583, longitude: 37.7506956710279), // Moscow
//            Location(latitude: 60.45343191228787, longitude: 59.2308017757992), // Mountains
//            Location(latitude: 60.28263967508878, longitude: 59.133942636342894), // Mountains
//            Location(latitude: 56.51280988140567, longitude: 32.87656229282573), // Forest
//            
//        ]
//        
//        for i in locations {
//            self.sendLocation(locModel: i)
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
