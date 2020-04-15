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
        annotationView.canShowCallout = true
        annotationView.image = UIImage(systemName: "airplane")
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


//Animations

extension MapView{
    
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
