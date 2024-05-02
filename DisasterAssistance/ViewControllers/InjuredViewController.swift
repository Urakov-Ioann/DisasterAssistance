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
    private let alertManager: AlertManagerProtocol = AlertManager()
    
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
        firestoreRepository.setLocation(locModel: locModel) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let action = ActionModel(title: "Хорошо", style: .cancel, actionBlock: nil)
                let alertModel = AlertModel(title: "Успешно", message: "Ваша геопозиция отправлена службам спасения", preferredStyle: .alert, actions: [action])
                self.alertManager.showAlert(from: self, alertModel: alertModel)
            case .failure:
                let action = ActionModel(title: "Хорошо", style: .cancel, actionBlock: nil)
                let alertModel = AlertModel(title: "Ошибка", message: "Ваша геопозиция не отправлена, попробуйте снова", preferredStyle: .alert, actions: [action])
                self.alertManager.showAlert(from: self, alertModel: alertModel)
            }
        }
    }
}
