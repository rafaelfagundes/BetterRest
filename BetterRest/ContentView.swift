//
//  ContentView.swift
//  BetterRest
//
//  Created by Rafael Fagundes on 2024-09-01.
//

import CoreML
import SwiftUI

struct ContentView: View {

  // User input
  @State private var wakeUpTime = defaultWakeUpTime
  @State private var sleepAmount = 8.0
  @State private var coffeAmount: Int = 1

  // Alert states
  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""

  // Default Wake Up Time
  static var defaultWakeUpTime: Date {
    let components = DateComponents(hour: 7, minute: 30)
    return Calendar.current.date(from: components) ?? Date.now
  }

  func calculateBedtime() {
    do {
      let config = MLModelConfiguration()
      let model = try SleepCalculator(configuration: config)

      let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
      let hour = (components.hour ?? 0) * 3600
      let minute = (components.minute ?? 0) * 60

      let prediction = try model.prediction(
        wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))

      let sleepTime = wakeUpTime - prediction.actualSleep

      alertTitle = "Your ideal bedtime is..."
      alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)

    } catch {
      alertTitle = "Error"
      alertMessage = "Sorry, there was an error calculating your bedtime"
    }

    showAlert = true
  }

  var body: some View {
    NavigationStack {
      Form {
        VStack(alignment: .leading, spacing: 0) {
          Text("When do you want to wake up?")
            .font(.headline)

          DatePicker(
            "Please enter a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute
          )
          .labelsHidden()
        }

        VStack(alignment: .leading, spacing: 0) {
          Text("How long do you want to sleep?")
            .font(.headline)

          Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
        }

        VStack(alignment: .leading, spacing: 0) {
          Text("Daily coffe intake")
            .font(.headline)

          Stepper("^[\(coffeAmount) cup](inflect: true)", value: $coffeAmount, in: 1...20, step: 1)
        }
      }
      .navigationTitle("Better Rest")
      .toolbar {
        Button("Calculate") {
          calculateBedtime()
        }
      }
      .alert(isPresented: $showAlert) {
        Alert(title: Text(alertTitle), message: Text(alertMessage))
      }
    }
  }
}

#Preview {
  ContentView()
}
