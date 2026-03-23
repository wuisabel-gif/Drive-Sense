import CoreLocation
import Foundation

struct TripPoint: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: Double
    let speedMetersPerSecond: Double
    let courseDegrees: Double

    init(location: CLLocation) {
        self.id = UUID()
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.speedMetersPerSecond = max(location.speed, 0)
        self.courseDegrees = location.course >= 0 ? location.course : 0
    }

    init(
        timestamp: Date,
        latitude: Double,
        longitude: Double,
        horizontalAccuracy: Double = 8,
        speedMetersPerSecond: Double,
        courseDegrees: Double
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.speedMetersPerSecond = speedMetersPerSecond
        self.courseDegrees = courseDegrees
    }
}

struct DrivingEvent: Codable, Identifiable {
    enum EventType: String, Codable {
        case harshBrake
        case rapidAcceleration
        case speeding
    }

    let id: UUID
    let timestamp: Date
    let type: EventType
    let severity: Double
}

struct TripSummary: Codable {
    var distanceMeters: Double
    var durationSeconds: Double
    var averageSpeedMetersPerSecond: Double
    var maxSpeedMetersPerSecond: Double
    var stoppedSeconds: Double
    var harshBrakeCount: Int
    var rapidAccelerationCount: Int
    var speedingCount: Int
    var smoothnessScore: Int
    var efficiencyScore: Int
    var tripScore: Int
    var aiNarrative: String?

    static let empty = TripSummary(
        distanceMeters: 0,
        durationSeconds: 0,
        averageSpeedMetersPerSecond: 0,
        maxSpeedMetersPerSecond: 0,
        stoppedSeconds: 0,
        harshBrakeCount: 0,
        rapidAccelerationCount: 0,
        speedingCount: 0,
        smoothnessScore: 100,
        efficiencyScore: 100,
        tripScore: 100,
        aiNarrative: nil
    )
}

struct TripRecord: Codable, Identifiable {
    enum Status: String, Codable {
        case recording
        case completed
    }

    let id: UUID
    var startedAt: Date
    var endedAt: Date?
    var status: Status
    var points: [TripPoint]
    var events: [DrivingEvent]
    var summary: TripSummary

    init(startedAt: Date = Date()) {
        self.id = UUID()
        self.startedAt = startedAt
        self.endedAt = nil
        self.status = .recording
        self.points = []
        self.events = []
        self.summary = .empty
    }
}

enum TripTrackingState: String {
    case idle
    case watching
    case candidateTrip
    case recording
    case ending

    var title: String {
        switch self {
        case .idle:
            return "Idle"
        case .watching:
            return "Watching for a drive"
        case .candidateTrip:
            return "Possible drive detected"
        case .recording:
            return "Recording trip"
        case .ending:
            return "Finishing trip"
        }
    }
}

enum PermissionState: String {
    case unknown
    case limited
    case ready
}

enum DemoScenario: String, CaseIterable, Identifiable, Codable {
    case cityCommute
    case highwayDrive
    case rushedTrip

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cityCommute:
            return "City Commute"
        case .highwayDrive:
            return "Highway Drive"
        case .rushedTrip:
            return "Rushed Trip"
        }
    }

    var subtitle: String {
        switch self {
        case .cityCommute:
            return "Balanced urban drive with lights and moderate traffic"
        case .highwayDrive:
            return "Faster sustained speeds with cleaner flow"
        case .rushedTrip:
            return "Aggressive starts and harder stops for client demos"
        }
    }
}

struct LiveTripMetrics {
    var currentSpeedMetersPerSecond: Double
    var distanceMeters: Double
    var elapsedSeconds: Double
    var stoppedSeconds: Double

    static let zero = LiveTripMetrics(
        currentSpeedMetersPerSecond: 0,
        distanceMeters: 0,
        elapsedSeconds: 0,
        stoppedSeconds: 0
    )
}
