//
//  CalendarModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 07/11/23.
//

import SwiftUI

struct CalendarModal: View {
    var geometry: GeometryProxy
    @State var currentDate: Date = Date()
    private let calendar = Calendar.current

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private var month: String {
        calendar.component(.month, from: currentDate).description
    }

    private var year: Int {
        calendar.component(.year, from: currentDate)
    }

    private var daysInMonth: [[Date?]] {
        calendar.generateDates(for: currentDate)
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(calendar.monthSymbols[calendar.component(.month, from: currentDate) - 1]) \(calendar.component(.year, from: currentDate).description)")
                    .font(.title)
                    .foregroundColor(.white)

                Spacer()
                Button(action: {
                    self.currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Button(action: {
                    self.currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            ForEach(daysInMonth, id: \.self) { week in
                HStack {
                    ForEach(week.indices, id: \.self) { index in
                        ZStack {
                            if let day = week[index] {
                                if self.calendar.isDateInToday(day) {
                                    Circle()
                                        .stroke(.white, lineWidth: 1)
                                        .fill(.tertiary)
                                        .frame(width: 30, height: 30)
                                }
                                
                                Text(self.dayFormatter.string(from: day))
                                    .foregroundColor(.white)
                            }
                            else {
                                Text("")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .padding(.horizontal, 32)
                    }
                }
            }
        }
        .padding(40)
        .frame(width: geometry.size.width * 0.35 - 80)
        .aspectRatio(1.45, contentMode: .fit)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 1)
        }
    }

    private func isToday(_ day: Date) -> Bool {
        calendar.isDateInToday(day)
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

