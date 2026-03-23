import Combine
import CoreLocation
import CoreMotion
import Foundation
import UIKit

final class DemoTripSimulator {
    private struct Sample {
        let speedMetersPerSecond: Double
        let courseDegrees: Double
    }

    private var timer: Timer?
    private var index = 0
    private var currentCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    private let tickSeconds: TimeInterval = 6
    private var scenario: DemoScenario = .cityCommute
    private var samples: [Sample] = []

    var onLocation: ((CLLocation) -> Void)?
    var onFinish: (() -> Void)?

    func start(scenario: DemoScenario) {
        stop()
        self.scenario = scenario
        self.samples = Self.samples(for: scenario)
        index = 0
        currentCoordinate = Self.coordinate(for: scenario)
        emitCurrentSample()
        timer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            self?.advance()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func makeCompletedTrip(for scenario: DemoScenario, startedAt: Date) -> TripRecord {
        self.scenario = scenario
        self.samples = Self.samples(for: scenario)
        self.currentCoordinate = Self.coordinate(for: scenario)

        var points: [TripPoint] = []
        for (index, sample) in samples.enumerated() {
            let distance = sample.speedMetersPerSecond * tickSeconds
            currentCoordinate = movedCoordinate(
                from: currentCoordinate,
                distanceMeters: distance,
                bearingDegrees: sample.courseDegrees
            )

            let timestamp = startedAt.addingTimeInterval(Double(index) * tickSeconds)
            points.append(
                TripPoint(
                    timestamp: timestamp,
                    latitude: currentCoordinate.latitude,
                    longitude: currentCoordinate.longitude,
                    speedMetersPerSecond: sample.speedMetersPerSecond,
                    courseDegrees: sample.courseDegrees
                )
            )
        }

        var trip = TripRecord(startedAt: startedAt)
        trip.points = points
        trip.endedAt = points.last?.timestamp ?? startedAt
        trip.status = .completed

        let (summary, events) = TripAnalyzer.buildSummary(for: trip)
        trip.summary = TripSummary(
            distanceMeters: summary.distanceMeters,
            durationSeconds: summary.durationSeconds,
            averageSpeedMetersPerSecond: summary.averageSpeedMetersPerSecond,
            maxSpeedMetersPerSecond: summary.maxSpeedMetersPerSecond,
            stoppedSeconds: summary.stoppedSeconds,
            harshBrakeCount: summary.harshBrakeCount,
            rapidAccelerationCount: summary.rapidAccelerationCount,
            speedingCount: summary.speedingCount,
            smoothnessScore: summary.smoothnessScore,
            efficiencyScore: summary.efficiencyScore,
            tripScore: summary.tripScore,
            aiNarrative: TripAnalyzer.buildNarrative(for: summary)
        )
        trip.events = events
        return trip
    }

    private func advance() {
        index += 1
        guard index < samples.count else {
            stop()
            onFinish?()
            return
        }
        emitCurrentSample()
    }

    private func emitCurrentSample() {
        let sample = samples[index]
        let distance = sample.speedMetersPerSecond * tickSeconds
        currentCoordinate = movedCoordinate(
            from: currentCoordinate,
            distanceMeters: distance,
            bearingDegrees: sample.courseDegrees
        )

        let location = CLLocation(
            coordinate: currentCoordinate,
            altitude: 12,
            horizontalAccuracy: 8,
            verticalAccuracy: 8,
            course: sample.courseDegrees,
            speed: sample.speedMetersPerSecond,
            timestamp: Date(timeIntervalSinceNow: Double(index) * tickSeconds)
        )
        onLocation?(location)
    }

    private static func samples(for scenario: DemoScenario) -> [Sample] {
        switch scenario {
        case .cityCommute:
            return [
                .init(speedMetersPerSecond: 0, courseDegrees: 0),
                .init(speedMetersPerSecond: 4, courseDegrees: 22),
                .init(speedMetersPerSecond: 9, courseDegrees: 28),
                .init(speedMetersPerSecond: 13, courseDegrees: 32),
                .init(speedMetersPerSecond: 17, courseDegrees: 35),
                .init(speedMetersPerSecond: 14, courseDegrees: 44),
                .init(speedMetersPerSecond: 6, courseDegrees: 62),
                .init(speedMetersPerSecond: 0, courseDegrees: 80),
                .init(speedMetersPerSecond: 0, courseDegrees: 80),
                .init(speedMetersPerSecond: 8, courseDegrees: 86),
                .init(speedMetersPerSecond: 15, courseDegrees: 93),
                .init(speedMetersPerSecond: 19, courseDegrees: 96),
                .init(speedMetersPerSecond: 22, courseDegrees: 96),
                .init(speedMetersPerSecond: 18, courseDegrees: 110),
                .init(speedMetersPerSecond: 11, courseDegrees: 126),
                .init(speedMetersPerSecond: 3, courseDegrees: 140),
                .init(speedMetersPerSecond: 0, courseDegrees: 160),
                .init(speedMetersPerSecond: 0, courseDegrees: 160)
            ]
        case .highwayDrive:
            return [
                .init(speedMetersPerSecond: 0, courseDegrees: 12),
                .init(speedMetersPerSecond: 8, courseDegrees: 20),
                .init(speedMetersPerSecond: 16, courseDegrees: 26),
                .init(speedMetersPerSecond: 23, courseDegrees: 28),
                .init(speedMetersPerSecond: 27, courseDegrees: 28),
                .init(speedMetersPerSecond: 31, courseDegrees: 30),
                .init(speedMetersPerSecond: 29, courseDegrees: 30),
                .init(speedMetersPerSecond: 30, courseDegrees: 32),
                .init(speedMetersPerSecond: 31, courseDegrees: 34),
                .init(speedMetersPerSecond: 30, courseDegrees: 38),
                .init(speedMetersPerSecond: 28, courseDegrees: 42),
                .init(speedMetersPerSecond: 24, courseDegrees: 44),
                .init(speedMetersPerSecond: 15, courseDegrees: 55),
                .init(speedMetersPerSecond: 6, courseDegrees: 75),
                .init(speedMetersPerSecond: 0, courseDegrees: 95),
                .init(speedMetersPerSecond: 0, courseDegrees: 95)
            ]
        case .rushedTrip:
            return [
                .init(speedMetersPerSecond: 0, courseDegrees: 4),
                .init(speedMetersPerSecond: 10, courseDegrees: 12),
                .init(speedMetersPerSecond: 18, courseDegrees: 16),
                .init(speedMetersPerSecond: 24, courseDegrees: 20),
                .init(speedMetersPerSecond: 12, courseDegrees: 35),
                .init(speedMetersPerSecond: 2, courseDegrees: 60),
                .init(speedMetersPerSecond: 0, courseDegrees: 60),
                .init(speedMetersPerSecond: 14, courseDegrees: 72),
                .init(speedMetersPerSecond: 22, courseDegrees: 76),
                .init(speedMetersPerSecond: 27, courseDegrees: 78),
                .init(speedMetersPerSecond: 13, courseDegrees: 104),
                .init(speedMetersPerSecond: 4, courseDegrees: 122),
                .init(speedMetersPerSecond: 0, courseDegrees: 130),
                .init(speedMetersPerSecond: 16, courseDegrees: 145),
                .init(speedMetersPerSecond: 25, courseDegrees: 152),
                .init(speedMetersPerSecond: 9, courseDegrees: 165),
                .init(speedMetersPerSecond: 0, courseDegrees: 175),
                .init(speedMetersPerSecond: 0, courseDegrees: 175)
            ]
        }
    }

    private static func coordinate(for scenario: DemoScenario) -> CLLocationCoordinate2D {
        switch scenario {
        case .cityCommute:
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        case .highwayDrive:
            return CLLocationCoordinate2D(latitude: 37.3387, longitude: -121.8853)
        case .rushedTrip:
            return CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        }
    }

    private func movedCoordinate(
        from coordinate: CLLocationCoordinate2D,
        distanceMeters: Double,
        bearingDegrees: Double
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0
        let bearing = bearingDegrees * .pi / 180
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        let angularDistance = distanceMeters / earthRadius

        let lat2 = asin(
            sin(lat1) * cos(angularDistance) +
            cos(lat1) * sin(angularDistance) * cos(bearing)
        )

        let lon2 = lon1 + atan2(
            sin(bearing) * sin(angularDistance) * cos(lat1),
            cos(angularDistance) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
}

final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var onLocation: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .automotiveNavigation
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 15
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlways() {
        manager.requestAlwaysAuthorization()
    }

    func startPassiveMonitoring() {
        manager.startMonitoringSignificantLocationChanges()
    }

    func startActiveTripUpdates() {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 10
        manager.startUpdatingLocation()
    }

    func stopActiveTripUpdates() {
        manager.stopUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 15
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations
            .filter { $0.horizontalAccuracy >= 0 }
            .forEach { onLocation?($0) }
    }
}

final class MotionActivityService {
    private let activityManager = CMMotionActivityManager()
    private let queue = OperationQueue()

    var onDrivingConfidence: ((Bool) -> Void)?

    func start() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }

        activityManager.startActivityUpdates(to: queue) { [weak self] activity in
            guard let activity else { return }
            let isDriving = activity.automotive && activity.confidence != .low
            DispatchQueue.main.async {
                self?.onDrivingConfidence?(isDriving)
            }
        }
    }

    func stop() {
        activityManager.stopActivityUpdates()
    }
}

final class TripStore: ObservableObject {
    @Published var trips: [TripRecord] = []

    private let saveURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let demoSimulator = DemoTripSimulator()

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.saveURL = documents.appendingPathComponent("trips.json")
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
        seedIfNeeded()
    }

    func upsert(_ trip: TripRecord) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.insert(trip, at: 0)
        }
        save()
    }

    private func save() {
        do {
            let data = try encoder.encode(trips)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("Failed to save trips: \(error.localizedDescription)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: saveURL)
            trips = try decoder.decode([TripRecord].self, from: data)
        } catch {
            trips = []
        }
    }

    private func seedIfNeeded() {
        guard trips.isEmpty else { return }

        let now = Date()
        let seeded = [
            demoSimulator.makeCompletedTrip(for: .cityCommute, startedAt: now.addingTimeInterval(-86_400)),
            demoSimulator.makeCompletedTrip(for: .highwayDrive, startedAt: now.addingTimeInterval(-172_800)),
            demoSimulator.makeCompletedTrip(for: .rushedTrip, startedAt: now.addingTimeInterval(-259_200))
        ]
        trips = seeded.sorted { ($0.startedAt) > ($1.startedAt) }
        save()
    }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var trips: [TripRecord] = []
    @Published var currentTrip: TripRecord?
    @Published var trackingState: TripTrackingState = .idle
    @Published var permissionState: PermissionState = .unknown
    @Published var statusMessage = "Waiting for permissions."
    @Published var liveMetrics: LiveTripMetrics = .zero
    @Published var isRunningDemoDrive = false
    @Published var selectedDemoScenario: DemoScenario = .cityCommute

    let store = TripStore()

    private let locationService = LocationService()
    private let motionService = MotionActivityService()
    private let demoSimulator = DemoTripSimulator()
    private var lastDrivingSignalAt: Date?
    private var lastMovementAt: Date?

    func configure() {
        bindStore()
        configureServices()
        trackingState = .watching
        statusMessage = "Ready to watch for a drive."
        locationService.startPassiveMonitoring()
        motionService.start()
        refreshPermissionState()
        configureDemoSimulator()
    }

    func requestWhenInUse() {
        locationService.requestWhenInUse()
    }

    func requestAlways() {
        locationService.requestAlways()
    }

    func startManualTrip() {
        beginTrip(at: Date())
    }

    func endManualTrip() {
        finishTrip()
    }

    func startDemoDrive() {
        guard currentTrip == nil else { return }
        isRunningDemoDrive = true
        statusMessage = "Running the \(selectedDemoScenario.title) demo scenario."
        beginTrip(at: Date())
        demoSimulator.start(scenario: selectedDemoScenario)
    }

    private func bindStore() {
        trips = store.trips
        store.$trips
            .receive(on: RunLoop.main)
            .assign(to: &$trips)
    }

    private func configureServices() {
        locationService.onAuthorizationChange = { [weak self] _ in
            self?.refreshPermissionState()
        }

        locationService.onLocation = { [weak self] location in
            self?.handle(location: location)
        }

        motionService.onDrivingConfidence = { [weak self] isDriving in
            self?.handleDrivingSignal(isDriving)
        }
    }

    private func configureDemoSimulator() {
        demoSimulator.onLocation = { [weak self] location in
            self?.handle(location: location)
        }
        demoSimulator.onFinish = { [weak self] in
            guard let self else { return }
            if self.currentTrip != nil {
                self.finishTrip()
            }
        }
    }

    private func refreshPermissionState() {
        let status = locationService.authorizationStatus
        permissionState = (status == .authorizedAlways || status == .authorizedWhenInUse) ? .ready : .limited

        if status == .authorizedAlways {
            statusMessage = "Background trip detection is enabled for automatic mileage logging."
        } else if status == .authorizedWhenInUse {
            statusMessage = "Tracking works best if you allow Always Location for automatic mileage logs."
        } else {
            statusMessage = "Location permission is needed to detect trips and build mileage records."
        }
    }

    private func handleDrivingSignal(_ isDriving: Bool) {
        guard isDriving else { return }
        lastDrivingSignalAt = Date()

        if currentTrip == nil {
            trackingState = .candidateTrip
            statusMessage = "Possible business drive detected. Waiting to confirm movement."
        }
    }

    private func handle(location: CLLocation) {
        guard location.horizontalAccuracy <= 65 else { return }

        let movingFastEnough = location.speed >= 4.5
        if movingFastEnough {
            lastMovementAt = location.timestamp
        }

        if currentTrip == nil {
            if shouldStartTrip(for: location) {
                beginTrip(at: location.timestamp)
                locationService.startActiveTripUpdates()
            }
            return
        }

        append(location: location)
        evaluateTripEnd(with: location)
    }

    private func shouldStartTrip(for location: CLLocation) -> Bool {
        let recentDrivingSignal = lastDrivingSignalAt.map { Date().timeIntervalSince($0) < 180 } ?? false
        return recentDrivingSignal || location.speed >= 6.0
    }

    private func beginTrip(at date: Date) {
        trackingState = .recording
        statusMessage = "Recording your drive for mileage tracking and behavior analysis."
        currentTrip = TripRecord(startedAt: date)
        liveMetrics = .zero
        store.upsert(currentTrip!)
    }

    private func append(location: CLLocation) {
        guard var trip = currentTrip else { return }
        trip.points.append(TripPoint(location: location))
        liveMetrics = buildLiveMetrics(for: trip)
        currentTrip = trip
        store.upsert(trip)
    }

    private func evaluateTripEnd(with location: CLLocation) {
        guard let lastMovementAt else { return }
        let isStopped = location.speed >= 0 && location.speed < 1.0
        let stoppedLongEnough = location.timestamp.timeIntervalSince(lastMovementAt) > 300

        if isStopped && stoppedLongEnough {
            trackingState = .ending
            statusMessage = "Finishing your mileage log and analyzing driving behavior."
            finishTrip()
        }
    }

    private func finishTrip() {
        guard var trip = currentTrip else { return }
        trip.endedAt = Date()
        trip.status = .completed

        let (summary, events) = TripAnalyzer.buildSummary(for: trip)
        trip.summary = TripSummary(
            distanceMeters: summary.distanceMeters,
            durationSeconds: summary.durationSeconds,
            averageSpeedMetersPerSecond: summary.averageSpeedMetersPerSecond,
            maxSpeedMetersPerSecond: summary.maxSpeedMetersPerSecond,
            stoppedSeconds: summary.stoppedSeconds,
            harshBrakeCount: summary.harshBrakeCount,
            rapidAccelerationCount: summary.rapidAccelerationCount,
            speedingCount: summary.speedingCount,
            smoothnessScore: summary.smoothnessScore,
            efficiencyScore: summary.efficiencyScore,
            tripScore: summary.tripScore,
            aiNarrative: TripAnalyzer.buildNarrative(for: summary)
        )
        trip.events = events

        currentTrip = nil
        liveMetrics = .zero
        isRunningDemoDrive = false
        trackingState = .watching
        statusMessage = "Trip saved. Mileage log updated and watching for your next drive."
        locationService.stopActiveTripUpdates()
        demoSimulator.stop()
        store.upsert(trip)
    }

    private func buildLiveMetrics(for trip: TripRecord) -> LiveTripMetrics {
        guard let first = trip.points.first, let last = trip.points.last else {
            return .zero
        }

        var distanceMeters = 0.0
        var stoppedSeconds = 0.0

        for index in 1..<trip.points.count {
            let previous = trip.points[index - 1]
            let current = trip.points[index]
            let start = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            let end = CLLocation(latitude: current.latitude, longitude: current.longitude)
            distanceMeters += end.distance(from: start)

            if current.speedMetersPerSecond < 1 {
                stoppedSeconds += current.timestamp.timeIntervalSince(previous.timestamp)
            }
        }

        return LiveTripMetrics(
            currentSpeedMetersPerSecond: last.speedMetersPerSecond,
            distanceMeters: distanceMeters,
            elapsedSeconds: last.timestamp.timeIntervalSince(first.timestamp),
            stoppedSeconds: stoppedSeconds
        )
    }
}
