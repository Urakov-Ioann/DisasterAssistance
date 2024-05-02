//
//  RescuerViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit
import YandexMapsMobile

class RescuerViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let landscapeHelper = LandscapeHelper()
    private let firestoreRepository: FirebaseRepositoryProtocol = FirebaseRepository(firebaseService: FirebaseService() as FirebaseServiceProtocol)
    private let alertManager: AlertManagerProtocol = AlertManager()
    
    // MARK: - UI Components
    
    private let showRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Показать маршруты спасения", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(createRoute), for: .touchUpInside)
        return button
    }()
    
    private let landscapeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Город", "Лес", "Горы", "Все"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 3
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(didSelectSegmenta(control: )), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var mapView: YMKMapView = YBaseMapView().mapView
    
    // MARK: - Properties
    
    private let controlItems: [LandscapeType] = [.city, .forest, .mountain, .all]
    private let drivingRouter: YMKDrivingRouter = YMKDirections.sharedInstance().createDrivingRouter(withType: .online)
    private let drivingOptions: YMKDrivingOptions = {
        let options = YMKDrivingOptions()
        options.routesCount = 100
        return options
    }()
    private var drivingSession: YMKDrivingSession?
    private var points = [YMKRequestPoint]()
    private var currentPoints = [YMKRequestPoint]()
    private var routesCollection: YMKMapObjectCollection!
    private var placemarks = [YMKPlacemarkMapObject]()
    private var routesToggle = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        routesCollection = mapView.mapWindow.map.mapObjects.add()
        firestoreRepository.getAllLocations { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let locationsModel):
                guard let locations = locationsModel else { return }
                for coordinate in locations {
                    let point = YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self.addPlacemark(mapView.mapWindow.map, point: point)
                    points.append(YMKRequestPoint(
                        point: point,
                        type: .viapoint,
                        pointContext: nil,
                        drivingArrivalPointId: nil)
                    )
                }
                currentPoints = points
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func addPlacemark(_ map: YMKMap, point: YMKPoint) {
        let image = UIImage(systemName: "circle") ?? UIImage()
        let placemark = map.mapObjects.addPlacemark()
        placemarks.append(placemark)
        placemark.geometry = point
        placemark.setIconWith(image)
    }
    
    private func drivingRouteHandler(drivingRoutes: [YMKDrivingRoute]?, error: Error?) {
        if let error {
            let action = ActionModel(title: "Понятно", style: .cancel, actionBlock: nil)
            let alertModel = AlertModel(title: "Ошибка", message: "В данной местности невозможно построить маршрут", preferredStyle: .alert, actions: [action])
            alertManager.showAlert(from: self, alertModel: alertModel)
            return
        }

        guard let drivingRoutes else {
            let action = ActionModel(title: "Понятно", style: .cancel, actionBlock: nil)
            let alertModel = AlertModel(title: "Ошибка", message: "В данной местности невозможно построить маршрут", preferredStyle: .alert, actions: [action])
            alertManager.showAlert(from: self, alertModel: alertModel)
            return
        }
        
        let route = drivingRoutes.sorted(by: { $0.metadata.weight.time.value < $1.metadata.weight.time.value })
        
        print("\n\n\nFIRST\n\n\n \(route.first?.metadata.weight.time.value)")
        print("\n\n\nLAST\n\n\n \(route.last?.metadata.weight.time.value)")
        
        guard let polyline = route.first?.geometry else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.routesToggle = false
            self.showRouteButton.setTitle("Скрыть маршруты спасения", for: .normal)
            self.drawRoute(polyline: polyline)
        }
    }
    
    private func drawRoute(polyline: YMKPolyline) {
        
        let polylineMapObject = routesCollection.addPolyline(with: polyline)
        polylineMapObject.strokeWidth = 5.0
        polylineMapObject.setStrokeColorWith(.gray)
        polylineMapObject.outlineWidth = 1.0
        polylineMapObject.outlineColor = .black
    }
    
    // MARK: - Actions
    
    @objc
    private func createRoute() {
        routesCollection.clear()
        if routesToggle {
            drivingSession = drivingRouter.requestRoutes(
                with: currentPoints,
                drivingOptions: drivingOptions,
                vehicleOptions: YMKDrivingVehicleOptions(),
                routeHandler: drivingRouteHandler
            )
        } else {
            routesToggle = true
            showRouteButton.setTitle("Показать маршруты спасения", for: .normal)
        }
    }
    
    @objc
    private func didSelectSegmenta(control: UISegmentedControl) {
        routesCollection.clear()
        showRouteButton.setTitle("Показать маршруты спасения", for: .normal)
        for object in placemarks {
            if object.isValid  {
                mapView.mapWindow.map.mapObjects.remove(with: object)
            }
        }
        
        currentPoints = []
        for point in points {
            let coordinate = Location(latitude: point.point.latitude, longitude: point.point.longitude)
            if landscapeHelper.isCoordinateInLandscap(controlItems[control.selectedSegmentIndex], coordinate: coordinate) {
                currentPoints.append(point)
                addPlacemark(mapView.mapWindow.map, point: point.point)
            }
        }
        
        currentPoints[0] = YMKRequestPoint(point: currentPoints[0].point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
        currentPoints[currentPoints.count - 1] = YMKRequestPoint(point: currentPoints[currentPoints.count - 1].point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
    }
}

private extension RescuerViewController {
    func setupViewController() {
        title = "Карта бедствий"
        addSubviews()
    }
    
    func addSubviews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        view.addSubview(showRouteButton)
        view.addSubview(landscapeSegmentedControl)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            landscapeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            landscapeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            showRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            showRouteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showRouteButton.heightAnchor.constraint(equalToConstant: 40),
            showRouteButton.widthAnchor.constraint(equalToConstant: showRouteButton.intrinsicContentSize.width + 16)
        ])
    }
}
