//
//  CalendarModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 07/11/23.
//

import SwiftUI

struct CalendarModal: View {
    @EnvironmentObject var store: AppStore
    var geometry: GeometryProxy

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private var month: String {
        store.state.calendar.component(.month, from: store.state.currentDate).description
    }

    private var year: Int {
        store.state.calendar.component(.year, from: store.state.currentDate)
    }

    private var daysInMonth: [[Date?]] {
        store.state.calendar.generateDates(for: store.state.currentDate)
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(store.state.calendar.monthSymbols[store.state.calendar.component(.month, from: store.state.currentDate) - 1]) \(store.state.calendar.component(.year, from: store.state.currentDate).description)")
                    .textCase(.uppercase)
                    .font(.system(size: 22))
                    .fontWeight(.heavy)
                    .fontWidth(.expanded)
                    .foregroundColor(store.state.uiColor)

                Spacer()
                
                Button(action: {
                    store.dispatch(.decreaseMonth)
                }) {
                    Image(systemName: "chevron.left")
                        .frame(alignment: .trailing)
                        .foregroundColor(store.state.uiColor)
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    store.dispatch(.increaseMonth)
                }) {
                    Image(systemName: "chevron.right")
                        .frame(alignment: .center)
                        .foregroundColor(store.state.uiColor)
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            ForEach(daysInMonth, id: \.self) { week in
                HStack {
                    ForEach(week.indices, id: \.self) { index in
                        ZStack {
                            if let day = week[index] {
                                if self.store.state.calendar.isDateInToday(day) {
                                    Circle()
                                        .fill(store.state.uiColor)
                                        .frame(width: 40, height: 40)
                                }
                                
                                Text(self.dayFormatter.string(from: day))
                                    .font(.system(size: 20))
                                    .foregroundColor(self.store.state.calendar.isDateInToday(day) ? .appBlack : store.state.uiColor)
                            }
                            else {
                                Text("")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .padding(40)
        .frame(width: geometry.size.width * 0.35 - 80)
        .aspectRatio(1.45, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
    }

    private func isToday(_ day: Date) -> Bool {
        store.state.calendar.isDateInToday(day)
    }
}

extension Calendar {
    func generateDates(for date: Date) -> [[Date?]] {
        let components = dateComponents([.year, .month], from: date)
        let startOfMonth = self.date(from: components)!
        let range = self.range(of: .day, in: .month, for: startOfMonth)!
        
        var monthArray = [[Date?]]()
        var weekArray = [Date?](repeating: nil, count: 7)

        for day in range {
            guard let date = self.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let weekday = self.component(.weekday, from: date)
            
            weekArray[weekday - 1] = date
            
            // Se é sábado ou último dia do mês, adicione a semana ao mês
            if weekday == 7 || day == range.count {
                monthArray.append(weekArray)
                weekArray = [Date?](repeating: nil, count: 7)
            }
        }
        
        // Certifique-se de adicionar a última semana se ela não foi adicionada
        if weekArray.contains(where: { $0 != nil }) {
            monthArray.append(weekArray)
        }
        
        return monthArray
    }
}

