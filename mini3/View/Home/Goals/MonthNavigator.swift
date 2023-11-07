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
            
            Spacer()
            
            Text(monthName.uppercased())
                .foregroundStyle(.black)
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.forward.circle")
                    .foregroundStyle(.black)
            }
            .clipShape(Circle())
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .aspectRatio(13.2, contentMode: .fit)
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
