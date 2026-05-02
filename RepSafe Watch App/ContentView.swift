//
//  ContentView.swift
//  RepSafe Watch App
//
//  Created by Hai Nguyen on 20/4/26.
//

import SwiftUI
import AVFoundation
import WatchKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ExerciseTrackingView()) {
                    Label("Workout Tracking", systemImage: "figure.strengthtraining.traditional")
                }

                NavigationLink(destination: EmergencySOSView()) {
                    Label("Emergency SOS", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
                
                NavigationLink(destination: DeviceIntegrationView()) {
                    Label("Device Sync", systemImage: "iphone.watchface")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("RepSafe")
        }
    }
}

struct APIConfig {
    static let baseURL = "http://172.20.10.2:8000"
    
    static var statusURL: URL? {
        URL(string: "\(baseURL)/status")
    }
}

extension View {
    @ViewBuilder func sensoryFeedback<T: Equatable>(if condition: Bool, _ feedback: SensoryFeedback, trigger: T) -> some View {
        if condition {
            self.sensoryFeedback(feedback, trigger: trigger)
        } else {
            self
        }
    }
}

struct RepCountingView: View {
    let targetReps: Int
    @State private var currentReps: Int = 0
    @State private var timer: Timer?
    
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    
    @AppStorage("voiceEnabled") private var voiceEnabled = false
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            Text("\(currentReps)/\(targetReps)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blue)
        }
        .navigationTitle("Counting")
        // Use the conditional extension
        .sensoryFeedback(if: hapticEnabled, .success, trigger: currentReps)
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
    }
    
    private func speak(_ number: Int) {
        let utterance = AVSpeechUtterance(string: "\(number)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            pollServer()
        }
    }

    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    private func pollServer() {
        guard let url = APIConfig.statusURL else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else { return }

            if let data = data,
               let statusText = String(data: data, encoding: .utf8)?
                   .trimmingCharacters(in: .whitespacesAndNewlines) {

                DispatchQueue.main.async {
                    if statusText == "COUNT" && currentReps < targetReps {
                        currentReps += 1
                        
                        if voiceEnabled {
                            speak(currentReps)
                        }
                    } else if statusText == "DESC" && currentReps > 0 {
                        currentReps -= 1
                        
                        if voiceEnabled {
                            speak(currentReps)
                        }
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Device Integration

struct DeviceIntegrationView: View {
    @State private var isConnected = false
    @State private var statusMessage = "Disconnected from Server"

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(isConnected ? .green : .red)

                Text(statusMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Button("Sync Now") {
                    pollServer()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Device Sync")
        .onAppear {
            // Automatically poll the server when the view appears
            pollServer()
        }
    }
    
    private func pollServer() {
        // Ensure that the IP address matches your local network IP of your laptop
        guard let url = APIConfig.statusURL else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error connecting to server: \(error)")
                    self.isConnected = false
                    self.statusMessage = "Disconnected from Server"
                    return
                }
                
                if let data = data, let statusText = String(data: data, encoding: .utf8) {
                    self.isConnected = true
                    self.statusMessage = "Connected to Server (State: \(statusText.trimmingCharacters(in: .whitespacesAndNewlines)))"
                } else {
                    self.isConnected = false
                    self.statusMessage = "No response from server"
                }
            }
        }.resume()
    }
}

// MARK: - Exercise Tracking

struct ExerciseTrackingView: View {
    @State private var reps = 12
    @State private var showCountingView = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Reps Count")
                    .font(.headline)

                Text("\(reps)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)

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
                
                Button("Start") {
                    showCountingView = true
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Workout")
        .navigationDestination(isPresented: $showCountingView) {
            RepCountingView(targetReps: reps)
        }
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

struct SettingsView: View {
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("voiceEnabled") private var voiceEnabled = false // NEW

    var body: some View {
        Form {
            Toggle("Haptic Feedback", isOn: $hapticEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            Toggle("Voice Counting", isOn: $voiceEnabled) // NEW
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .navigationTitle("Settings")
    }
}

struct SOSTestCondition1View: View {
    @State private var countdown = 10
    @State private var timer: Timer?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Emergency Alert")
                .font(.headline)
                .foregroundColor(.red)

            Text("Condition 1: Beep sound")
                .font(.caption2)
                .foregroundColor(.gray)

            Text("\(countdown)s")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            Button(action: {
                cancelSOS()
            }) {
                Text("Cancel SOS")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .navigationTitle("SOS Test 1")
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
                playBeep()
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func playBeep() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #else
        AudioServicesPlaySystemSound(1052)
        #endif
    }

    private func cancelSOS() {
        stopTimer()
        dismiss()
    }
}

struct SOSTestCondition2View: View {
    @State private var countdown = 10
    @State private var timer: Timer?
    @Environment(\.dismiss) var dismiss

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Emergency Alert")
                .font(.headline)
                .foregroundColor(.red)

            Text("Condition 2: Haptic feedback")
                .font(.caption2)
                .foregroundColor(.gray)

            Text("\(countdown)s")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            GeometryReader { geometry in
                let maxDrag = geometry.size.width - 60
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 50)

                    Text("Swipe right to cancel")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)

                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.red)
                        .frame(width: 46, height: 46)
                        .padding(2)
                        .offset(x: max(0, min(dragOffset, maxDrag)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if gesture.translation.width > 0 && gesture.translation.width <= maxDrag {
                                        dragOffset = gesture.translation.width
                                    }
                                }
                                .onEnded { _ in
                                    if dragOffset > maxDrag / 2 {
                                        cancelSOS()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
        }
        .navigationTitle("SOS Test 2")
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
                triggerHaptic()
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func triggerHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.notification)
        #endif
    }

    private func cancelSOS() {
        stopTimer()
        dismiss()
    }
}

#Preview {
    ContentView()
}
