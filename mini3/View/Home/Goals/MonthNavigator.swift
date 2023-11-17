//
//  MonthNavigator.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct MonthNavigator: View {
    @EnvironmentObject var store: AppStore
    private let dateFormatter = DateFormatter()

    var body: some View {
        HStack {
            
            Spacer()
            
            Button(action: {store.dispatch(.decreaseMonth)}) {
                Image(systemName: "chevron.backward.circle")
            }
            .buttonStyle(.plain)
            
            Text(monthName.capitalized)
                .padding(.horizontal, 22)
            
            Button(action: {store.dispatch(.increaseMonth)}) {
                Image(systemName: "chevron.forward.circle")
                    
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .font(.system(size: 20, weight: .regular))
        .fontWidth(.expanded)
        .foregroundStyle(Color.appBlack)
        .padding(8)
        .frame(maxWidth: .infinity)
        .aspectRatio(13.2, contentMode: .fit)
        .background(store.state.uiColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var monthName: String {
        dateFormatter.monthSymbols[store.state.calendar.component(.month, from: store.state.currentDate) - 1]
    }
}
