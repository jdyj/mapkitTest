//
//  ViewController.swift
//  mapkitTest
//
//  Created by 조재영 on 2022/03/20.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController {

  @IBOutlet weak var mapView: MapKitView!

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.configure()
  }
  
}

