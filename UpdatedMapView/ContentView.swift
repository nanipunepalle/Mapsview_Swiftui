//
//  ContentView.swift
//  UpdatedMapView
//
//  Created by Lalith on 14/04/20.
//  Copyright © 2020 NANI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var sourceCity: String = ""
    @State private var destinationCity: String = ""
    @State private var selection: Int? = nil
    @State private var intermediateCity: String = ""
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter the source city",text: $sourceCity)
                    .padding(10)
                    .font(Font.system(size: 25))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red,lineWidth: 1))
                TextField("Enter the destination city",text: $destinationCity)
                    .padding(10)
                    .font(Font.system(size: 25))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red,lineWidth: 1))
                TextField("Enter intermediate city if any",text: $intermediateCity)
                    .padding(10)
                    .font(Font.system(size: 25))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red,lineWidth: 1))
                    .padding(.bottom)
                NavigationLink(destination: MapView(sourceCity: sourceCity, destinationCity: destinationCity, intermediateCity: intermediateCity), tag: 1, selection: $selection) {
                    Button(action: {
                        self.selection = 1
                    }) {
                        Text("Continue").font(.system(size: 25)).foregroundColor(.white)
                    }.frame(width: 318, height: 50)
                        .background(Color(.red)).cornerRadius(20)
                }
            }.padding().navigationBarTitle(Text("")
            .foregroundColor(.red),displayMode: .inline)

        }    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
