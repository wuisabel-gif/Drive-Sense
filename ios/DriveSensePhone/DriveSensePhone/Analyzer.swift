import CoreLocation
import Foundation

enum TripAnalyzer {
    private static let stoppedSpeedThreshold = 1.0
    private static let harshBrakeThreshold = -3.2
    private static let rapidAccelerationThreshold = 2.8
    private static let speedingThreshold = 31.3

    static func buildSummary(for trip: TripRecord) -> (TripSummary, [DrivingEvent]) {
        guard trip.points.count > 1 else {
            return (.empty, [])
        }

        var distanceMeters = 0.0
        var durationSeconds = 0.0
        var stoppedSeconds = 0.0
        var maxSpeed = 0.0
        var events: [DrivingEvent] = []
        var previousEventType: DrivingEvent.EventType?

        for index in 1..<trip.points.count {
            let previous = trip.points[index - 1]
            let current = trip.points[index]

            let startLocation = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            let endLocation = CLLocation(latitude: current.latitude, longitude: current.longitude)
            let deltaTime = current.timestamp.timeIntervalSince(previous.timestamp)
            guard deltaTime > 0 else { continue }

            durationSeconds += deltaTime
            distanceMeters += endLocation.distance(from: startLocation)
            maxSpeed = max(maxSpeed, current.speedMetersPerSecond)

            if current.speedMetersPerSecond <= stoppedSpeedThreshold {
                stoppedSeconds += deltaTime
            }

            let acceleration = (current.speedMetersPerSecond - previous.speedMetersPerSecond) / deltaTime
            let eventType: DrivingEvent.EventType?
            let severity: Double

            if acceleration <= harshBrakeThreshold {
                eventType = .harshBrake
                severity = abs(acceleration)
            } else if acceleration >= rapidAccelerationThreshold {
                eventType = .rapidAcceleration
                severity = acceleration
            } else if current.speedMetersPerSecond >= speedingThreshold {
                eventType = .speeding
                severity = current.speedMetersPerSecond
            } else {
                eventType = nil
                severity = 0
            }

            if let eventType, previousEventType != eventType {
                events.append(DrivingEvent(id: UUID(), timestamp: current.timestamp, type: eventType, severity: severity))
                previousEventType = eventType
            } else if eventType == nil {
                previousEventType = nil
            }
        }

        let averageSpeed = durationSeconds > 0 ? distanceMeters / durationSeconds : 0
        let harshBrakes = events.filter { $0.type == .harshBrake }.count
        let rapidAccelerations = events.filter { $0.type == .rapidAcceleration }.count
        let speedingCount = events.filter { $0.type == .speeding }.count

        let smoothness = clamp(100 - (harshBrakes * 12 + rapidAccelerations * 10))
        let efficiency = clamp(100 - Int(stoppedSeconds / 60.0 * 6.0) - rapidAccelerations * 4)
        let tripScore = clamp(Int(Double(smoothness) * 0.45 + Double(efficiency) * 0.35 + Double(max(0, 100 - speedingCount * 15)) * 0.20))

        let summary = TripSummary(
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds,
            averageSpeedMetersPerSecond: averageSpeed,
            maxSpeedMetersPerSecond: maxSpeed,
            stoppedSeconds: stoppedSeconds,
            harshBrakeCount: harshBrakes,
            rapidAccelerationCount: rapidAccelerations,
            speedingCount: speedingCount,
            smoothnessScore: smoothness,
            efficiencyScore: efficiency,
            tripScore: tripScore,
            aiNarrative: nil
        )

        return (summary, events)
    }

    static func buildNarrative(for summary: TripSummary) -> String {
        let miles = summary.distanceMeters * 0.000621371
        let minutes = summary.durationSeconds / 60
        let averageMph = summary.averageSpeedMetersPerSecond * 2.23694

        var parts: [String] = []
        parts.append(String(format: "This trip covered %.1f miles in %.0f minutes.", miles, minutes))

        if summary.stoppedSeconds >= 180 {
            parts.append("Stopped time was noticeable, which likely reduced efficiency.")
        } else {
            parts.append("The drive kept moving at a fairly steady pace.")
        }

        if summary.harshBrakeCount > 0 || summary.rapidAccelerationCount > 0 {
            parts.append("Driving behavior showed \(summary.harshBrakeCount) harsh braking events and \(summary.rapidAccelerationCount) rapid accelerations.")
        } else {
            parts.append("Driving behavior was generally smooth.")
        }

        parts.append(String(format: "Average speed was %.1f mph and the trip scored %d out of 100.", averageMph, summary.tripScore))
        return parts.joined(separator: " ")
    }

    private static func clamp(_ value: Int) -> Int {
        min(100, max(0, value))
    }
}
