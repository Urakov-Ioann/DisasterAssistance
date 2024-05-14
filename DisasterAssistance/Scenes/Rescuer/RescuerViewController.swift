//
//  RescuerViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit
import YandexMapsMobile

struct DisasterPoint {
    let point: YMKRequestPoint
    let numOfVictims: String
    let disasterType: String
    let injuresType: String
}

struct DisasterPointWithMapOject {
    let point: YMKRequestPoint
    let mapObject: YMKMapObject
    let numOfVictims: String
    let disasterType: String
    let injuresType: String
    
    init(point: DisasterPoint, mapObject: YMKMapObject) {
        self.point = point.point
        self.mapObject = mapObject
        self.numOfVictims = point.numOfVictims
        self.disasterType = point.disasterType
        self.injuresType = point.injuresType
    }
    
    init(point: YMKRequestPoint,
                     mapObject: YMKMapObject,
                     numOfVictims: String,
                     disasterType: String,
                     injuresType: String) {
        self.point = point
        self.mapObject = mapObject
        self.numOfVictims = numOfVictims
        self.disasterType = disasterType
        self.injuresType = injuresType
    }
}

class RescuerViewController: UIViewController, YMKMapObjectTapListener {
    
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
    private var points = [DisasterPoint]()
    private var currentPoints = [DisasterPointWithMapOject]()
    private var routesCollection: YMKMapObjectCollection!
    private var linesCollection: YMKMapObjectCollection!
    private var placemarks = [YMKPlacemarkMapObject]()
    private var routesToggle = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        routesCollection = mapView.mapWindow.map.mapObjects.add()
        linesCollection = mapView.mapWindow.map.mapObjects.add()
        firestoreRepository.getAllLocations { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let locationsModel):
                guard let locations = locationsModel else { return }
                for model in locations {
                    let point = YMKPoint(latitude: model.location.latitude, longitude: model.location.longitude)
                    let disasterPoint = DisasterPoint(
                        point: YMKRequestPoint(
                            point: point,
                            type: .viapoint,
                            pointContext: nil,
                            drivingArrivalPointId: nil
                        ),
                        numOfVictims: model.numberOfVictims,
                        disasterType: model.typeOfDisaster,
                        injuresType: model.typeOfInjures
                    )
                    self.addPlacemark(mapView.mapWindow.map, point: disasterPoint)
                    points.append(disasterPoint)
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func addPlacemark(_ map: YMKMap, point: DisasterPoint) {
        let image1 = UIImage(named: "whiteCircle") ?? UIImage()
        let placemark1 = map.mapObjects.addPlacemark()
        placemarks.append(placemark1)
        placemark1.geometry = point.point.point
        placemark1.setIconWith(image1)
        let image = UIImage(named: "greenCircle") ?? UIImage()
        let placemark = map.mapObjects.addPlacemark()
        placemark.addTapListener(with: self)
        placemarks.append(placemark)
        placemark.geometry = point.point.point
        placemark.setIconWith(image)
        currentPoints.append(DisasterPointWithMapOject(point: point, mapObject: placemark))
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
        let polylineMapObject = linesCollection.addPolyline(with: polyline)
        polylineMapObject.strokeWidth = 4.0
        polylineMapObject.setStrokeColorWith(color)
    }
    
func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 8
    currentPoints.forEach {
        if $0.mapObject == mapObject {
            let action = ActionModel(
                title: "Понятно",
                style: .default,
                actionBlock: nil
            )
            let alertModel = AlertModel(
                title: "Информация о бедствии",
                message: "Вид бедствия: \($0.disasterType)\nКоличество пострадавших: \($0.numOfVictims)\nТипы травм: \($0.injuresType)",
                preferredStyle: .actionSheet,
                actions: [action]
            )
            alertManager.showAlert(from: self, alertModel: alertModel)
        }
    }
    return true
}
    
    // MARK: - Actions
    
    @objc
    private func createRoute() {
        var curPoints = [YMKRequestPoint]()
        
        currentPoints.forEach { curPoints.append($0.point) }
        if routesToggle {
            drivingSession = drivingRouter.requestRoutes(
                with: curPoints,
                drivingOptions: drivingOptions,
                vehicleOptions: YMKDrivingVehicleOptions(),
                routeHandler: drivingRouteHandler
            )
        } else {
            routesCollection.clear()
            routesToggle = true
            showRouteButton.setTitle("Показать маршруты спасения", for: .normal)
        }
    }
    
    @objc
    private func didSelectSegmenta(control: UISegmentedControl) {
        routesToggle = true
        routesCollection.clear()
        if let linesCollection = linesCollection {
            linesCollection.clear()
        }
        showRouteButton.setTitle("Показать маршруты спасения", for: .normal)
        for object in placemarks {
            if object.isValid  {
                mapView.mapWindow.map.mapObjects.remove(with: object)
            }
        }
        
        
        var jarvisPoints = [Location]()
        currentPoints = []
        for point in points {
            let coordinate = Location(latitude: point.point.point.latitude, longitude: point.point.point.longitude)
            if landscapeHelper.isCoordinateInLandscape(controlItems[control.selectedSegmentIndex], coordinate: coordinate) {
                jarvisPoints.append(coordinate)
                addPlacemark(mapView.mapWindow.map, point: point)
            }
        }
        
        guard control.selectedSegmentIndex != 3 else { return }
        guard !currentPoints.isEmpty else { return }
        
        currentPoints[0] = DisasterPointWithMapOject(
            point: YMKRequestPoint(point: currentPoints[0].point.point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil),
            mapObject: currentPoints[0].mapObject,
            numOfVictims: currentPoints[0].numOfVictims,
            disasterType: currentPoints[0].disasterType,
            injuresType: currentPoints[0].injuresType
        )
        
        currentPoints[currentPoints.count - 1] = DisasterPointWithMapOject(
            point: YMKRequestPoint(point: currentPoints[currentPoints.count - 1].point.point, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil),
            mapObject: currentPoints[currentPoints.count - 1].mapObject,
            numOfVictims: currentPoints[currentPoints.count - 1].numOfVictims,
            disasterType: currentPoints[currentPoints.count - 1].disasterType,
            injuresType: currentPoints[currentPoints.count - 1].injuresType)
        
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

// MARK: - Setup constraints

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
