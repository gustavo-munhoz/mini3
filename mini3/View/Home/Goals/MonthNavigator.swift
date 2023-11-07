//
//  MonthNavigator.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct MonthNavigator: View {
    @Binding var currentMonth: Int
    private let dateFormatter = DateFormatter()

    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.backward.circle")
                    .foregroundStyle(.black)
            }
            .clipShape(Circle())
            
            Text(monthName.uppercased())
                .foregroundStyle(.black)
                .font(.system(size: 15))
            
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.forward.circle")
                    .foregroundStyle(.black)
            }
            .clipShape(Circle())
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 39)
        
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
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
