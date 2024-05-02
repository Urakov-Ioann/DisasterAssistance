//
//  AlertModels.swift
//  ARHitBalls
//
//  Created by Иоанн Ураков on 02.05.2024.
//

import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    let preferredStyle: UIAlertController.Style
    let actions: [ActionModel]
}

struct ActionModel {
    let title: String?
    let style: UIAlertAction.Style
    let actionBlock: (() -> Void)?
}
