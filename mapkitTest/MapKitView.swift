//
//  MapKitView.swift
//  mapkitTest
//
//  Created by 조재영 on 2022/03/29.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class MapKitView: MKMapView {

  @IBOutlet weak var mapView: MKMapView!

  var previousCoordinate: CLLocationCoordinate2D?
  var locationManager = CLLocationManager()
  var currentLocation: CLLocation!
  let motionManager = CMMotionActivityManager()

  private var distance = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpXib()
    }

    private func setUpXib() {
        // 메타데이터 스트링화
        let name = String(describing: self)
        // nib 파일 만듬
        let nib = UINib(nibName: name, bundle: nil)

        // 인스턴스화
        guard let view = nib.instantiate(withOwner: self, options: nil)
                .first as? UIView else {
                    fatalError("failed to instantiate MapKitView")
                }

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)

    }

  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
      setUpXib()
  }

  func configure() {
//    self.mapView.mapType = MKMapType.standard
//    self.mapView.showsUserLocation = true
//    self.mapView.setUserTrackingMode(.follow, animated: true)
////    initMotion()
//    mapView.delegate = self
//    // 현재위치 색상 바꾸기
////    mapView.tintColor = UIColor.green
//    locationManager.delegate = self
//    // 정확도를 최고로 설정
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    // 위치 데이터를 추적하기 위해 사용자에게 승인 요구
//    locationManager.requestWhenInUseAuthorization()
//    // 위치 업데이트를 시작
//    locationManager.startUpdatingLocation()
//    // Do any additional setup after loading the view.
  }

  func initMotion() {
    locationManager.distanceFilter = 10
    motionManager.startActivityUpdates(to: .main) {
      activity in guard let activity = activity else { return }
        if activity.running == true || activity.walking == true {
          if activity.stationary == false {
            self.locationManager.startUpdatingLocation()
            print("user motion is running or walking and not stationary")
            print(activity)

          } else {
            self.locationManager.stopUpdatingLocation()
            print("user motion is running or walking but stationary")
            print(activity)
          }

        } else {
          self.locationManager.stopUpdatingLocation()
          print("user motion is not running or walking")
          print(activity)
        }

    }

  }


}

extension MapKitView: CLLocationManagerDelegate {

  // 위도와 경도, 스팬(영역 폭)을 입력받아 지도에 표시
  func goLocation(latitudeValue: CLLocationDegrees,
                  longtudeValue: CLLocationDegrees,
                  delta span: Double) -> CLLocationCoordinate2D {
      let pLocation = CLLocationCoordinate2DMake(latitudeValue, longtudeValue)
      let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
      let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
      mapView.setRegion(pRegion, animated: true)
      return pLocation
  }


  func setAnnotation(latitudeValue: CLLocationDegrees,
                         longitudeValue: CLLocationDegrees,
                         delta span :Double,
                         title strTitle: Int) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = goLocation(latitudeValue: latitudeValue, longtudeValue: longitudeValue, delta: span)

    annotation.title = "\(strTitle) m"
    mapView.addAnnotation(annotation)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    guard let location = locations.last
    else {return}
    let latitude = location.coordinate.latitude
    let longtitude = location.coordinate.longitude


    if let previousCoordinate = self.previousCoordinate {
      var points: [CLLocationCoordinate2D] = []
      let point1 = CLLocationCoordinate2DMake(previousCoordinate.latitude, previousCoordinate.longitude)
      let point2: CLLocationCoordinate2D
      = CLLocationCoordinate2DMake(latitude, longtitude)
      points.append(point1)
      points.append(point2)
      let lineDraw = MKPolyline(coordinates: points, count:points.count)

      let test1 = CLLocation(latitude: previousCoordinate.latitude, longitude: previousCoordinate.longitude)

      let test2 = CLLocation(latitude: latitude, longitude: longtitude)

      distance += Int(test2.distance(from: test1))
      if distance % 10 == 0 {
        setAnnotation(latitudeValue: latitude, longitudeValue: longtitude, delta: 0.001, title: distance)
      }
      self.mapView.addOverlay(lineDraw)
    }

    self.previousCoordinate = location.coordinate
  }


}

extension MapKitView: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyLine = overlay as? MKPolyline
    else {
        print("can't draw polyline")
        return MKOverlayRenderer()
    }
    let renderer = MKPolylineRenderer(polyline: polyLine)
    renderer.strokeColor = .blue
    renderer.fillColor = .blue
    renderer.lineWidth = 5.0
    renderer.alpha = 1.0

    return renderer
  }
  func mapView(_mapView:MKMapView,didChangemode:MKUserTrackingMode,animated: Bool) {
      mapView.setUserTrackingMode(.followWithHeading, animated: true)
  }


}
