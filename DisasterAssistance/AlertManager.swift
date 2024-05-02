//
//  AlertManager.swift
//  ARHitBalls
//
//  Created by Иоанн Ураков on 02.05.2024.
//

import UIKit

protocol AlertManagerProtocol {
    func showAlert(
        fromViewController viewController: UIViewController?,
        title: String?,
        message: String?,
        firstButtonTitle: String?,
        firstActionBlock: (() -> Void)?,
        secondTitleButton: String?,
        secondActionBlock: (() -> Void)?
    )
    func showAlert(
        fromViewController viewController: UIViewController?,
        title: String?,
        message: String?,
        firstButtonTitle: String?,
        firstActionBlock: (() -> Void)?
    )
    func showAlert(
        from viewController: UIViewController?,
        alertModel: AlertModel
    )
}

final class AlertManager {}

extension AlertManager: AlertManagerProtocol {
    func showAlert(
        fromViewController viewController: UIViewController?,
        title: String?,
        message: String?,
        firstButtonTitle: String?,
        firstActionBlock: (() -> Void)?,
        secondTitleButton: String?,
        secondActionBlock: (() -> Void)?
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let firstAction = UIAlertAction(
            title: firstButtonTitle,
            style: .default,
            handler: { _ in
            firstActionBlock?()
        })
        
        let secondAction = UIAlertAction(
            title: secondTitleButton,
            style: .default,
            handler: { _ in
            secondActionBlock?()
        })
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        
        viewController?.present(alertController, animated: true)
    }
    
    func showAlert(
        fromViewController viewController: UIViewController?,
        title: String?,
        message: String?,
        firstButtonTitle: String?,
        firstActionBlock: (() -> Void)?
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let firstAction = UIAlertAction(
            title: firstButtonTitle,
            style: .default,
            handler: { _ in
            firstActionBlock?()
        })
        
        alertController.addAction(firstAction)
        
        viewController?.present(alertController, animated: true)
    }
    
    func showAlert(
        from viewController: UIViewController?,
        alertModel: AlertModel
    ) {
        let alertController = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: alertModel.preferredStyle
        )
        
        for actionModel in alertModel.actions {
            let action = UIAlertAction(
                title: actionModel.title,
                style: actionModel.style,
                handler: { _ in
                actionModel.actionBlock?()
            })
            alertController.addAction(action)
        }
        viewController?.present(
            alertController,
            animated: true
        )
    }
}
