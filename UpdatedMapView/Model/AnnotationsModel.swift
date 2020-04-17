//
//  AnnotationsModel.swift
//  UpdatedMapView
//
//  Created by Lalith  on 17/04/20.
//  Copyright © 2020 NANI. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var slope: Double!
    var isslope: Bool = false
}

class CoordinateAnnotation: MKPointAnnotation {
    var imageName: String!
}
