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
    private let jarvisHelper = JarvisHelper()
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
                    let point = YMKPoint(latitude: coordinate.location.latitude, longitude: coordinate.location.longitude)
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
        let image1 = UIImage(named: "whiteCircle") ?? UIImage()
        let placemark1 = map.mapObjects.addPlacemark()
        placemarks.append(placemark1)
        placemark1.geometry = point
        placemark1.setIconWith(image1)
        let image = UIImage(named: "greenCircle") ?? UIImage()
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
        
        guard route.isEmpty == false else {
            let action = ActionModel(title: "Понятно", style: .cancel, actionBlock: nil)
            let alertModel = AlertModel(title: "Ошибка", message: "В данной местности невозможно построить маршрут", preferredStyle: .alert, actions: [action])
            alertManager.showAlert(from: self, alertModel: alertModel)
            return
        }
        
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
        polylineMapObject.strokeWidth = 4.0
        polylineMapObject.setStrokeColorWith(.systemGreen)
    }
    
    private func drawLine(polyline: YMKPolyline, color: UIColor) {
        let polylineMapObject = routesCollection.addPolyline(with: polyline)
        polylineMapObject.strokeWidth = 4.0
        polylineMapObject.setStrokeColorWith(color)
    }
    
    // MARK: - Actions
    
    @objc
    private func createRoute() {
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
        routesToggle = true
        routesCollection.clear()
        showRouteButton.setTitle("Показать маршруты спасения", for: .normal)
        for object in placemarks {
            if object.isValid  {
                mapView.mapWindow.map.mapObjects.remove(with: object)
            }
        }
        
        var jarvisPoints = [Location]()
        currentPoints = []
        for point in points {
            let coordinate = Location(latitude: point.point.latitude, longitude: point.point.longitude)
            if landscapeHelper.isCoordinateInLandscap(controlItems[control.selectedSegmentIndex], coordinate: coordinate) {
                currentPoints.append(point)
                jarvisPoints.append(coordinate)
                addPlacemark(mapView.mapWindow.map, point: point.point)
            }
        }
        guard !currentPoints.isEmpty else { return }
        
        currentPoints[0] = YMKRequestPoint(point: currentPoints[0].point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
        currentPoints[currentPoints.count - 1] = YMKRequestPoint(point: currentPoints[currentPoints.count - 1].point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
        
        if currentPoints.count > 2 {
            let hullList = jarvisHelper.convexHull(points: jarvisPoints)
            for i in 1..<hullList.count {
                self.drawLine(
                    polyline: YMKPolyline(points: [
                        YMKPoint(latitude: hullList[i].latitude, longitude: hullList[i].longitude),
                        YMKPoint(latitude: hullList[i-1].latitude, longitude: hullList[i-1].longitude),
                    ]),
                    color: .red
                )
                if i == hullList.count - 1 {
                    self.drawLine(
                        polyline: YMKPolyline(points: [
                            YMKPoint(latitude: hullList[0].latitude, longitude: hullList[0].longitude),
                            YMKPoint(latitude: hullList[i].latitude, longitude: hullList[i].longitude),
                        ]),
                        color: .red
                    )
                }
            }
        }
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
