//
//  InjuredViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class InjuredViewController: UIViewController {

    @IBOutlet weak var otherInformationButton: UIButton!
    
    private let firestoreRepository: FirebaseRepositoryProtocol = FirebaseRepository(firebaseService: FirebaseService() as FirebaseServiceProtocol)
    private let locationService: LocationServiceProtocol = LocationService()
    private let alertManager: AlertManagerProtocol = AlertManager()
    
    private var uuidOfDisaster: UUID?
    private var locationOfDisaster: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Экран пострадавшего"
        otherInformationButton.layer.cornerRadius = 12
        otherInformationButton.layer.borderColor = UIColor.black.cgColor
        otherInformationButton.layer.borderWidth = 1
    }
    
    @IBAction func reportButtonAction(_ sender: Any) {
        guard let cllocation = locationService.getCurrentLocation() else { return }
        let location = Location(latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude)
        self.locationOfDisaster = location
        
        let disasterModel = DisasterModel(location: location, numberOfVictims: "нет информации", typeOfDisaster: "нет информации", typeOfInjures: "нет информации")
        
        self.sendLocation(locModel: disasterModel)
    }
    
    private func sendLocation(locModel: DisasterModel) {
        uuidOfDisaster = UUID()
        guard let documentName = uuidOfDisaster else { return}
        firestoreRepository.setLocation(
            documentName: documentName.uuidString,
            locModel: locModel
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let action = ActionModel(title: "Хорошо", style: .cancel, actionBlock: nil)
                let alertModel = AlertModel(title: "Успешно", message: "Ваша геопозиция отправлена службам спасения", preferredStyle: .alert, actions: [action])
                self.alertManager.showAlert(from: self, alertModel: alertModel)
                self.otherInformationButton.isEnabled = true
            case .failure:
                let action = ActionModel(title: "Хорошо", style: .cancel, actionBlock: nil)
                let alertModel = AlertModel(title: "Ошибка", message: "Ваша геопозиция не отправлена, попробуйте снова", preferredStyle: .alert, actions: [action])
                self.alertManager.showAlert(from: self, alertModel: alertModel)
            }
        }
    }
    
    @IBAction func moreInfoButtonAction(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle:nil)
        let otherInfoVC = story.instantiateViewController(withIdentifier: "OtherInformationVC") as! OtherInformationViewController
        otherInfoVC.documentName = uuidOfDisaster?.uuidString
        otherInfoVC.firestoreRepository = firestoreRepository
        otherInfoVC.location = locationOfDisaster
        
        navigationController?.showDetailViewController(otherInfoVC, sender: self)
    }
}
