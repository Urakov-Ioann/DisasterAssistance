//
//  OtherInformationViewController.swift
//  DisasterAssistance
//
//  Created by Максим Косников on 03.05.2024.
//

import UIKit

class OtherInformationViewController: UIViewController {
    
    var firestoreRepository: FirebaseRepositoryProtocol?
    
    var location: Location?
    var documentName: String?
    private var disasterType: String = "Землетрясение"
    private var injureType: String = "Переломы"
    private var numOfVictims: String = "1"
    private let disasterTypes = ["Землетрясение", "Пожар", "Оползень"]
    private let injures = ["Переломы", "Ожоги", "Без сознания"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendOtherInfoButtonAction(_ sender: Any) {
        guard let documentName = documentName,
              let location = location
        else { return }
        
        let locModel = DisasterModel(location: location, numberOfVictims: numOfVictims, typeOfDisaster: disasterType, typeOfInjures: injureType)
        firestoreRepository?.updateLocation(documentName: documentName, locModel: locModel, completion: { _ in
            self.dismiss(animated: true)
        })
    }
}

extension OtherInformationViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag{
        case 0:
            return disasterTypes[row]
        case 1:
            return String(row + 1)
        case 2:
            return injures[row]
        default:
            return "0"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag{
        case 0:
            print(disasterTypes[row])
        case 1:
            print(row + 1)
        case 2:
            print(injures[row])
        default:
            break
        }
    }
}

extension OtherInformationViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return disasterTypes.count
        case 1:
            return 100
        case 2:
            return injures.count
        default:
            return 1
        }
    }
}
