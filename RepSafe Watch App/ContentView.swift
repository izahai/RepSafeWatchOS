//
//  ContentView.swift
//  RepSafe Watch App
//
//  Created by Hai Nguyen on 20/4/26.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: DeviceIntegrationView()) {
                    Label("Device Sync", systemImage: "iphone.watchface")
                }

                NavigationLink(destination: ExerciseTrackingView()) {
                    Label("Workout Tracking", systemImage: "figure.strengthtraining.traditional")
                }

                NavigationLink(destination: FatigueMonitoringView()) {
                    Label("Fatigue Monitor", systemImage: "heart.text.square")
                }

                NavigationLink(destination: EmergencySOSView()) {
                    Label("Emergency SOS", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("RepSafe")
        }
    }
}

// MARK: - Device Integration

struct DeviceIntegrationView: View {
    @State private var isConnected = true

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(isConnected ? .green : .red)

                Text(isConnected ? "Connected to iPhone" : "Disconnected")
                    .font(.headline)

                Toggle("Sync Enabled", isOn: $isConnected)

                Button("Sync Now") {}
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Device Sync")
    }
}

// MARK: - Exercise Tracking

struct ExerciseTrackingView: View {
    @State private var reps = 12
    @State private var isTracking = true

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Reps Count")
                    .font(.headline)

                Text("\(reps)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)

                Toggle("Auto Tracking", isOn: $isTracking)

                HStack {
                    Button("-") {
                        reps = max(0, reps - 1)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)

                    Button("+") {
                        reps += 1
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Workout")
    }
}

// MARK: - Fatigue Monitoring

struct FatigueMonitoringView: View {
    @State private var heartRate = 128
    @State private var fatigueAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Heart Rate")
                    .font(.headline)

                Text("\(heartRate) BPM")
                    .font(.title2)
                    .foregroundColor(.pink)

                Toggle("Fatigue Alerts", isOn: $fatigueAlert)

                Text(fatigueAlert ? "Monitoring Active" : "Monitoring Off")
                    .font(.caption)
                    .foregroundColor(.gray)

                Button("Simulate Alert") {
                    fatigueAlert.toggle()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Fatigue")
    }
}

// MARK: - Emergency SOS

struct EmergencySOSView: View {
    @State private var sosEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.largeTitle)
                    .foregroundColor(.red)

                Text("Emergency SOS")
                    .font(.headline)

                Toggle("Auto Detect", isOn: $sosEnabled)

                Button(role: .destructive) {
                    // Demo only
                } label: {
                    Text("Trigger SOS")
                        .frame(maxWidth: .infinity)
                }

                Text("Will alert emergency contacts")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("SOS")
    }
}

#Preview {
    ContentView()
}
