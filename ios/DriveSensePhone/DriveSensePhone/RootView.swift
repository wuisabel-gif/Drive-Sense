import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "car.fill")
                }

            TripsView()
                .tabItem {
                    Label("Trips", systemImage: "list.bullet.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusCard
                    permissionsCard
                    currentTripCard
                    if appModel.currentTrip != nil {
                        liveTripCard
                    }
                    latestTripCard
                }
                .padding()
            }
            .navigationTitle("DriveSense")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tracking Status")
                .font(.headline)
            Text(appModel.trackingState.title)
                .font(.title3.weight(.semibold))
            Text(appModel.statusMessage)
                .foregroundStyle(.secondary)
            Text("Built to help business drivers track deductible mileage and review driving habits over time.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var permissionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .font(.headline)
            Text(permissionMessage)
                .foregroundStyle(.secondary)

            HStack {
                Button("Allow Location") {
                    appModel.requestWhenInUse()
                }
                .buttonStyle(.borderedProminent)

                Button("Upgrade to Always") {
                    appModel.requestAlways()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var currentTripCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip Control")
                .font(.headline)

            if let currentTrip = appModel.currentTrip {
                Text("Recording since \(currentTrip.startedAt.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.secondary)

                Button("End Current Trip") {
                    appModel.endManualTrip()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Use this in Simulator or during early testing if automatic detection has not started a trip yet. The demo is great for showing business mileage tracking and driving-habit review.")
                    .foregroundStyle(.secondary)

                Picker("Demo Scenario", selection: $appModel.selectedDemoScenario) {
                    ForEach(DemoScenario.allCases) { scenario in
                        Text(scenario.title).tag(scenario)
                    }
                }
                .pickerStyle(.segmented)

                Text(appModel.selectedDemoScenario.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Start Demo Drive") {
                        appModel.startDemoDrive()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Start Manual Trip") {
                        appModel.startManualTrip()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var liveTripCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live Trip")
                    .font(.headline)
                Spacer()
                if appModel.isRunningDemoDrive {
                    Text("Demo")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.orange.opacity(0.18), in: Capsule())
                }
            }

            let miles = Measurement(value: appModel.liveMetrics.distanceMeters, unit: UnitLength.meters)
                .converted(to: .miles)
                .formatted(.measurement(width: .abbreviated, usage: .road))
            let mph = appModel.liveMetrics.currentSpeedMetersPerSecond * 2.23694
            let gaugeProgress = min(max(mph / 80.0, 0), 1)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: gaugeProgress)
                        .stroke(
                            AngularGradient(
                                colors: [.green, .yellow, .orange, .red],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 4) {
                        Text(String(format: "%.0f", mph))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text("mph")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 170)

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                    GridRow {
                        metricBox(title: "Distance", value: miles)
                        metricBox(title: "Elapsed", value: String(format: "%.0f sec", appModel.liveMetrics.elapsedSeconds))
                    }
                    GridRow {
                        metricBox(title: "Stopped", value: String(format: "%.0f sec", appModel.liveMetrics.stoppedSeconds))
                        metricBox(title: "Scenario", value: appModel.selectedDemoScenario.title)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private var latestTripCard: some View {
        if let latestTrip = appModel.trips.first(where: { $0.status == .completed }) {
            NavigationLink {
                TripDetailView(trip: latestTrip)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latest Trip")
                        .font(.headline)
                    Text("\(Measurement(value: latestTrip.summary.distanceMeters, unit: UnitLength.meters).converted(to: .miles).formatted(.measurement(width: .abbreviated, usage: .road))) in \(String(format: "%.0f", latestTrip.summary.durationSeconds / 60)) min")
                        .font(.title3.weight(.semibold))
                    Text(latestTrip.summary.aiNarrative ?? "Trip summary will appear here after analysis.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        }
    }

    private var permissionMessage: String {
        switch appModel.permissionState {
        case .ready:
            return "Location permission is ready. Always Location improves automatic trip capture for business mileage logs and background trip history."
        case .limited:
            return "The app needs location access to detect drives. Motion and Always Location make business mileage tracking and habit evaluation more reliable."
        case .unknown:
            return "Request permissions to let the app watch for likely drives and build automatic mileage records."
        }
    }

    private func metricBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct TripsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            List(appModel.trips.filter { $0.status == .completed }) { trip in
                NavigationLink {
                    TripDetailView(trip: trip)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.startedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        Text("\(trip.summary.tripScore)/100 trip score · \(Measurement(value: trip.summary.distanceMeters, unit: UnitLength.meters).converted(to: .miles).formatted(.measurement(width: .abbreviated, usage: .road)))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Trips")
        }
    }
}

struct TripDetailView: View {
    let trip: TripRecord

    var body: some View {
        List {
            summarySection
            narrativeSection
            eventsSection
        }
        .navigationTitle("Trip Detail")
    }

    private var summarySection: some View {
        Section("Summary") {
            metricRow(title: "Distance", value: Measurement(value: trip.summary.distanceMeters, unit: UnitLength.meters).converted(to: .miles).formatted(.measurement(width: .abbreviated, usage: .road)))
            metricRow(title: "Duration", value: String(format: "%.0f min", trip.summary.durationSeconds / 60))
            metricRow(title: "Average Speed", value: String(format: "%.1f mph", trip.summary.averageSpeedMetersPerSecond * 2.23694))
            metricRow(title: "Top Speed", value: String(format: "%.1f mph", trip.summary.maxSpeedMetersPerSecond * 2.23694))
            metricRow(title: "Stopped Time", value: String(format: "%.1f min", trip.summary.stoppedSeconds / 60))
            metricRow(title: "Trip Score", value: "\(trip.summary.tripScore)/100")
            metricRow(title: "Smoothness", value: "\(trip.summary.smoothnessScore)/100")
            metricRow(title: "Efficiency", value: "\(trip.summary.efficiencyScore)/100")
        }
    }

    private var narrativeSection: some View {
        Section("AI Summary") {
            Text(trip.summary.aiNarrative ?? "No summary generated yet.")
        }
    }

    private var eventsSection: some View {
        Section("Events") {
            if trip.events.isEmpty {
                Text("No major driving events were detected.")
            } else {
                ForEach(trip.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.type.rawValue)
                            .font(.headline)
                        Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("How It Works") {
                    Text("DriveSense uses iPhone motion activity plus location changes to detect likely drives, then records higher-accuracy GPS only during an active trip so business mileage is easier to log and review.")
                }

                Section("Phone-Only Metrics") {
                    Text("Distance, duration, average speed, top speed, stopped time, harsh braking estimates, rapid acceleration estimates, and business mileage tracking for tax reporting.")
                }

                Section("Business Use") {
                    Text("DriveSense is designed to help self-employed drivers, small business owners, and contractors keep cleaner mileage records for income tax filing while also reviewing driving habits and trip quality.")
                }

                Section("Future Upgrade") {
                    Text("Vehicle data like fuel use, RPM, and engine temperature would require an OBD-II connection later.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
