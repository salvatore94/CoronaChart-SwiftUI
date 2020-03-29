//
//  ContentView.swift
//  ChartingCorona
//
//  Created by Salvatore  Polito on 29/03/2020.
//  Copyright © 2020 Salvatore  Polito. All rights reserved.
//

import SwiftUI

struct TimeSeries : Decodable {
    let Italy : [DayData]
}

struct DayData : Decodable, Hashable {
    let date : String
    let confirmed, deaths, recovered : Int
}

class ChartViewModel : ObservableObject {
    
    @Published var dataSet = [DayData]()
    
    var max = 0
    
    init() {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //need to check error
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("data == nil")
                return
            }
            
            do {
                let timeSeries = try JSONDecoder().decode(TimeSeries.self, from: data)
                
                DispatchQueue.main.async {
                    self.dataSet = timeSeries.Italy.filter { $0.deaths > 0 }
                    
                    self.max = self.dataSet.max(by: { (day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                        })?.deaths ?? 0
                }

            } catch {
                print(error.localizedDescription)
            }
            
        }.resume()
    }
}

struct ContentView: View {
    @ObservedObject var vm = ChartViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            Text("Corona").font(.system(size: 36, weight:
                .bold, design: .rounded))
            Text("Total deaths in Italy: \(vm.max)")
            
            
            if !vm.dataSet.isEmpty {
                ScrollView (.horizontal) {
                    HStack (alignment: .bottom, spacing: 4){
                        ForEach(vm.dataSet, id: \.self) { day in
                            
                            HStack {
                                Spacer()
                            }.frame(width: 8, height: (CGFloat(day.deaths)/CGFloat(self.vm.max)) * 400).background(Color.red)
                            
                        }
                    }
                }
                
            }
            Spacer()
            
//            HStack {
//                VStack {
//                    Spacer()
//                }.frame(width: 10, height: 200).background(Color.red)
//
//                VStack {
//                    Spacer()
//                }.frame(width: 10, height: 200).background(Color.red)
//
//                VStack {
//                    Spacer()
//                }.frame(width: 10, height: 200).background(Color.red)
//            }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
