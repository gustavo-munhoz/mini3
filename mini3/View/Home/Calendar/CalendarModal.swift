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
    
    @State private var didPressIncrease = false
    @State private var didPressDecrease = false
    
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
        ZStack {
            VStack(spacing: 24) {
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
                        didPressDecrease.toggle()
                    }) {
                        Image(systemName: "chevron.left")
                            .frame(alignment: .trailing)
                            .foregroundColor(store.state.uiColor)
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .speed(3), value: didPressDecrease)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        store.dispatch(.increaseMonth)
                        didPressIncrease.toggle()
                    }) {
                        Image(systemName: "chevron.right")
                            .frame(alignment: .center)
                            .foregroundColor(store.state.uiColor)
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .speed(3), value: didPressIncrease)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                VStack {
                    HStack(spacing: 22) {
                        ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { dayOfWeek in
                            Text(dayOfWeek)
                                .font(.system(size: 16))
                                .fontWeight(.thin)
                                .frame(width: 40 + 20)
                                .foregroundColor(store.state.uiColor)
                        }
                    }
                    
                    ForEach(daysInMonth, id: \.self) { week in
                        HStack(spacing: 22) {
                            ForEach(week.indices, id: \.self) { index in
                                ZStack {
                                    if let day = week[index] {
                                        if self.store.state.calendar.isDateInToday(day) {
                                            Circle()
                                                .fill(store.state.uiColor)
                                                .frame(width: 40, height: 40)
                                        }
                                        
                                        Text(self.dayFormatter.string(from: day))
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(self.store.state.calendar.isDateInToday(day) ? .appBlack : store.state.uiColor)
                                    }
                                    else {
                                        Text("")
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .padding(.horizontal, 10)
                            }
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
            .opacity((store.state.onboardingState != .calendar && store.state.onboardingState != .finished) ? 0.3 : 1)
            
            if store.state.onboardingState == .calendar {
                CalendarOnboardingOverlayView()
                    .offset(x: -geometry.size.width * 0.235, y: -geometry.size.height * 0.066)
            }
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
            
            if weekday == 7 || day == range.count {
                monthArray.append(weekArray)
                weekArray = [Date?](repeating: nil, count: 7)
            }
        }
        
        if weekArray.contains(where: { $0 != nil }) {
            monthArray.append(weekArray)
        }
        
        return monthArray
    }
}
