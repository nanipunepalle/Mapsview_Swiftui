//
//  MapView.swift
//  UpdatedMapView
//
//  Created by Lalith on 14/04/20.
//  Copyright © 2020 NANI. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

struct MapView: UIViewRepresentable {
    
    @State var sourceCity: String
    @State var destinationCity: String
    @State var intermediateCity: String?
    @State var sourceCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State var destinationCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State var intermediateCoordinates: CLLocationCoordinate2D?
    let myGroup = DispatchGroup()
    
    let sourceAnnotation = CoordinateAnnotation()
    let destinationAnnotation = CoordinateAnnotation()
    let intermediateAnnotation = CoordinateAnnotation()
    let movingAnnotaion = CustomPointAnnotation()
    let locationManager = LocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        return MKMapView(frame: .zero)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        var noCities = 2
        var count = 0
        sourceAnnotation.imageName = "plane"
        destinationAnnotation.imageName = "plane"
        intermediateAnnotation.imageName = "plane"
        movingAnnotaion.imageName = "plane"
        if intermediateCity != ""{
            noCities = 3
        }
        uiView.delegate = context.coordinator
        uiView.addAnnotations([sourceAnnotation,destinationAnnotation,intermediateAnnotation,movingAnnotaion])
        
        myGroup.enter()
        
        self.locationManager.getCoordinate(addressString: self.sourceCity) { (coordinate, error) in
            if error != nil {
                print(error ?? "error")
            }
            else{
                self.sourceCoordinates = coordinate
                count += 1
                self.check(count: count, noCities: noCities)
            }
            
        }
        self.locationManager.getCoordinate(addressString: self.destinationCity) { (coordinate, error) in
            if error != nil {
                print(error ?? "error")
            }
            else{
                self.destinationCoordinates = coordinate
                count += 1
                self.check(count: count, noCities: noCities)
            }
        }
        
        if intermediateCity != ""{
            self.locationManager.getCoordinate(addressString: self.intermediateCity!) { (coordinate, error) in
                if error != nil {
                    print(error ?? "error")
                }
                else{
                    self.intermediateCoordinates = coordinate
                    count += 1
                    self.check(count: count, noCities: noCities)
                }
            }
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            
            
            self.sourceAnnotation.coordinate = self.sourceCoordinates
            self.destinationAnnotation.coordinate = self.destinationCoordinates
            
            if self.intermediateCoordinates != nil{
                let iSlope = self.findSlope(sCoord: self.sourceCoordinates, dcord: self.intermediateCoordinates!)
                let dSlope = self.findSlope(sCoord: self.intermediateCoordinates!, dcord: self.destinationCoordinates)
                self.intermediateAnnotation.coordinate = self.intermediateCoordinates!
                let routeLine1 = MKPolyline(coordinates: [self.sourceCoordinates,self.intermediateCoordinates!,self.destinationCoordinates], count: 3)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                uiView.addOverlay(routeLine1)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                self.animation1(iSlope: iSlope, dSlope: dSlope, uiView: uiView)
            }
            else if self.intermediateCoordinates == nil{
                self.checkCoordinates(sourceCoordinates: self.sourceCoordinates, destinationCoordinates: self.destinationCoordinates)
                let slope = self.findSlope(sCoord: self.sourceCoordinates,dcord: self.destinationCoordinates)
                self.movingAnnotaion.slope = slope
                let routeLine1 = MKPolyline(coordinates: [self.sourceCoordinates,self.destinationCoordinates], count: 2)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                uiView.addOverlay(routeLine1)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                self.animation2()
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(sourceCity: "", destinationCity: "")
    }
}


extension UIImage{
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

//Animations





