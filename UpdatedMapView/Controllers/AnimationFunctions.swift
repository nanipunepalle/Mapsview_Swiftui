//
//  AnimationFunctions.swift
//  UpdatedMapView
//
//  Created by Lalith  on 17/04/20.
//  Copyright © 2020 NANI. All rights reserved.
//

import Foundation
import MapKit

extension MapView{
    
    
    //Animation if there is intermediate stop
    func animation1(iSlope: Double,dSlope: Double,uiView: MKMapView){
        updateMovingAnnotation(slope: iSlope, uiView: uiView)
        self.checkCoordinates(sourceCoordinates: self.sourceCoordinates, destinationCoordinates: self.intermediateCoordinates!)
        UIView.animate(withDuration: 1,animations: {
            self.movingAnnotaion.coordinate = self.sourceCoordinates
        }) { done in
            if done{
                UIView.animate(withDuration: 30, animations: {
                    self.movingAnnotaion.coordinate = self.intermediateCoordinates!
                }) { suceess in
                    if suceess{
                        self.updateMovingAnnotation(slope: dSlope, uiView: uiView)
                        self.checkCoordinates(sourceCoordinates: self.intermediateCoordinates!, destinationCoordinates: self.destinationCoordinates)
                        UIView.animate(withDuration: 1, animations: {
                            self.movingAnnotaion.coordinate = self.intermediateCoordinates!
                        }) { complete in
                            if complete{
                                UIView.animate(withDuration: 30, animations: {
                                    self.movingAnnotaion.coordinate = self.destinationCoordinates
                                }) { (success) in
                                    self.animation1(iSlope: iSlope,dSlope: dSlope, uiView: uiView)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    

    //Animation if there is no intermediatestop
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
        if count == noCities{
            myGroup.leave()
        }
    }
    
    
    //Functions to point the annottaion according to route by finding slope of the route and checking latitudes and longitudes
    func findSlope(sCoord: CLLocationCoordinate2D,dcord: CLLocationCoordinate2D) -> Double{
        let slope = (dcord.longitude - sCoord.longitude)/(dcord.latitude - sCoord.latitude)
        return slope
    }
    func checkCoordinates(sourceCoordinates: CLLocationCoordinate2D,destinationCoordinates: CLLocationCoordinate2D){
        if sourceCoordinates.latitude > destinationCoordinates.latitude{
            self.movingAnnotaion.isslope = true
        }
        else{
            self.movingAnnotaion.isslope = false
        }
    }
    
    //Update the animating annotation
    func updateMovingAnnotation(slope: Double,uiView: MKMapView){
        uiView.removeAnnotation(self.movingAnnotaion)
        uiView.addAnnotation(self.movingAnnotaion)
        self.movingAnnotaion.slope = slope
    }
}
