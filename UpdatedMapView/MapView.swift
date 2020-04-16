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
    @State private var sourceCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var destinationCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var intermediateCoordinates: CLLocationCoordinate2D?
    let myGroup = DispatchGroup()
    
    let sourceAnnotation = MKPointAnnotation()
    let destinationAnnotation = MKPointAnnotation()
    let intermediateAnnotation = MKPointAnnotation()
    let movingAnnotaion = MKPointAnnotation()
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
                self.intermediateAnnotation.coordinate = self.intermediateCoordinates!
                let routeLine1 = MKPolyline(coordinates: [self.sourceCoordinates,self.intermediateCoordinates!,self.destinationCoordinates], count: 3)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                uiView.addOverlay(routeLine1)
                uiView.setRegion(MKCoordinateRegion(routeLine1.boundingMapRect), animated: true)
                self.animation1()
            }
            else if self.intermediateCoordinates == nil{
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


class Coordinator: NSObject,MKMapViewDelegate{
    
    var mapViewController: MapView
    init(_ control: MapView) {
        self.mapViewController = control
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "view")
        annotationView.canShowCallout = false
        let image = UIImage(named: "plane")
        let sizedImage = image!.resizedImage(newSize: CGSize(width: 60, height: 60))
        annotationView.image = sizedImage
        let radians = 90 * Double.pi/180
        annotationView.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        return annotationView
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .red
        render.lineWidth = 3
        render.lineDashPhase = 2
        render.lineDashPattern = [1,5]
        return render
    }
}


extension UIImage{
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func rotate(degrees: CGFloat) -> UIImage {
        let radians = degrees / (180.0 * CGFloat.pi)
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

//Animations

extension MapView{
    
//    func findSlope() -> Double{
//        
//        let slope = (destinationCoordinates.longitude - sourceCoordinates.longitude)/(destinationCoordinates.latitude - sourceCoordinates.la)
//        return slope
//    }
    
    func animation1(){
        UIView.animate(withDuration: 1,animations: {
            self.movingAnnotaion.coordinate = self.sourceCoordinates
        }) { suc in
            if suc{
                UIView.animate(withDuration: 30, animations: {
                    self.movingAnnotaion.coordinate = self.intermediateCoordinates!
                }) { suceess in
                    if suceess{
                        UIView.animate(withDuration: 30, animations: {
                            self.movingAnnotaion.coordinate = self.destinationCoordinates
                        }) { (success) in
                            self.animation1()
                        }
                        
                    }
                }
            }
        }
    }
    
    func animation2(){
        UIView.animate(withDuration: 1, animations: {
            self.movingAnnotaion.coordinate = self.sourceCoordinates
        }) { success in
            if success{
                UIView.animate(withDuration: 30, animations: {
                    self.movingAnnotaion.coordinate = self.destinationCoordinates
                }) { done in
                    if done{
                        self.animation2()
                    }
                }
            }
        }
    }
    
    func check(count: Int,noCities: Int){
        print(count)
        print(noCities)
        if count == noCities{
            myGroup.leave()
        }
    }
}
