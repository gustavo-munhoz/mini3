//
//  MonthNavigator.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct MonthNavigator: View {
    @EnvironmentObject var store: AppStore
    @Binding var currentMonth: Int
    private let dateFormatter = DateFormatter()

    var body: some View {
        HStack {
            
            Spacer()
            
            Button(action: previousMonth) {
                Image(systemName: "chevron.backward.circle")
                    .foregroundStyle(Color.appBlack)
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(monthName.uppercased())
                .foregroundStyle(Color("AppBlack"))
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.forward.circle")
                    .foregroundStyle(Color.appBlack)
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .aspectRatio(13.2, contentMode: .fit)
        .background(store.state.uiColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var monthName: String {
        dateFormatter.monthSymbols[currentMonth - 1]
    }

    private func previousMonth() {
        currentMonth = currentMonth == 1 ? 12 : currentMonth - 1
    }

    private func nextMonth() {
        currentMonth = currentMonth == 12 ? 1 : currentMonth + 1
    }
}


#Preview {
    MonthNavigator(currentMonth: .constant(1))
}
