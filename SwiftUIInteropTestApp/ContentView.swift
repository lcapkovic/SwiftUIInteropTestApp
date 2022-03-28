//
//  ContentView.swift
//  SwiftUIInteropTestApp
//
//  Created by Lukas Capkovic on 3/27/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TestPage1()
            TestPage2()
            TestPage3()
            TestPage4()
        }.tabViewStyle(.page)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
