#include "analyzer.h"

#include <algorithm>
#include <cmath>
#include <iomanip>
#include <sstream>
#include <string>

namespace {
constexpr double kIdleSpeedMph = 1.0;
constexpr double kHardBrakeMphPerSec = -0.5;
constexpr double kRapidAccelMphPerSec = 0.3;
constexpr double kStopAndGoThresholdMph = 12.0;
constexpr double kSpeedingThresholdMph = 60.0;

double clampScore(double score) {
    return std::max(0.0, std::min(100.0, score));
}

std::string formatDouble(double value, int precision = 1) {
    std::ostringstream out;
    out << std::fixed << std::setprecision(precision) << value;
    return out.str();
}
}

TripSummary analyzeTrip(const std::vector<TripPoint>& points) {
    TripSummary summary;
    summary.maxSpeedMph = points.front().speedMph;
    summary.maxEngineTempC = points.front().engineTempC;

    double totalTimeSeconds = 0.0;
    double totalDistanceMiles = 0.0;
    double idleTimeSeconds = 0.0;
    double peakThrottle = points.front().throttlePercent;

    bool previousWasStopAndGo = false;
    bool previousWasHardBrake = false;
    bool previousWasRapidAccel = false;
    bool previousWasSpeeding = false;

    for (size_t i = 1; i < points.size(); ++i) {
        const TripPoint& previous = points[i - 1];
        const TripPoint& current = points[i];

        const double deltaTime = current.timeSeconds - previous.timeSeconds;
        if (deltaTime <= 0.0) {
            continue;
        }

        totalTimeSeconds += deltaTime;
        totalDistanceMiles += ((previous.speedMph + current.speedMph) / 2.0) * (deltaTime / 3600.0);

        if (current.speedMph <= kIdleSpeedMph && current.rpm > 0.0) {
            idleTimeSeconds += deltaTime;
        }

        const double accelerationMphPerSec = (current.speedMph - previous.speedMph) / deltaTime;
        const bool isHardBrake = accelerationMphPerSec <= kHardBrakeMphPerSec && current.brakePercent >= 20.0;
        const bool isRapidAccel = accelerationMphPerSec >= kRapidAccelMphPerSec && current.throttlePercent >= 25.0;
        const bool isStopAndGo = current.speedMph < kStopAndGoThresholdMph && current.throttlePercent > 10.0;
        const bool isSpeeding = current.speedMph >= kSpeedingThresholdMph;

        if (isHardBrake && !previousWasHardBrake) {
            ++summary.hardBrakeEvents;
        }
        if (isRapidAccel && !previousWasRapidAccel) {
            ++summary.rapidAccelEvents;
        }
        if (isStopAndGo && !previousWasStopAndGo) {
            ++summary.stopAndGoMoments;
        }
        if (isSpeeding && !previousWasSpeeding) {
            ++summary.speedingMoments;
        }

        previousWasHardBrake = isHardBrake;
        previousWasRapidAccel = isRapidAccel;
        previousWasStopAndGo = isStopAndGo;
        previousWasSpeeding = isSpeeding;

        summary.maxSpeedMph = std::max(summary.maxSpeedMph, current.speedMph);
        summary.maxEngineTempC = std::max(summary.maxEngineTempC, current.engineTempC);
        peakThrottle = std::max(peakThrottle, current.throttlePercent);
    }

    summary.totalDistanceMiles = totalDistanceMiles;
    summary.durationMinutes = totalTimeSeconds / 60.0;
    summary.averageSpeedMph = totalTimeSeconds > 0.0 ? totalDistanceMiles / (totalTimeSeconds / 3600.0) : 0.0;
    summary.idleMinutes = idleTimeSeconds / 60.0;
    summary.fuelUsedGallons = std::max(0.0, points.front().fuelGallons - points.back().fuelGallons);
    summary.estimatedMpg = summary.fuelUsedGallons > 0.0 ? summary.totalDistanceMiles / summary.fuelUsedGallons : 0.0;

    summary.smoothnessScore = clampScore(
        100.0 - summary.hardBrakeEvents * 10.0 - summary.rapidAccelEvents * 7.0 - summary.stopAndGoMoments * 3.0);

    summary.efficiencyScore = clampScore(
        85.0 - summary.idleMinutes * 4.0 - summary.rapidAccelEvents * 5.0 - summary.stopAndGoMoments * 2.5 +
        std::min(summary.estimatedMpg, 20.0));

    summary.tripScore = clampScore(
        0.45 * summary.smoothnessScore + 0.35 * summary.efficiencyScore +
        0.20 * clampScore(100.0 - summary.speedingMoments * 15.0));

    if (summary.idleMinutes >= 3.0) {
        summary.notes.push_back("Idle time was elevated and likely reduced fuel efficiency.");
    }
    if (summary.hardBrakeEvents > 0) {
        summary.notes.push_back("Hard braking suggests traffic pressure or late reaction points.");
    }
    if (summary.rapidAccelEvents > 0) {
        summary.notes.push_back("Rapid acceleration was detected and may indicate less efficient throttle use.");
    }
    if (summary.stopAndGoMoments >= 3) {
        summary.notes.push_back("The trip included repeated stop-and-go conditions.");
    }
    if (summary.speedingMoments > 0) {
        summary.notes.push_back("Speed exceeded the configured highway threshold at least once.");
    }
    if (summary.maxEngineTempC >= 105.0) {
        summary.notes.push_back("Engine temperature peaked higher than expected and is worth monitoring.");
    }
    if (summary.notes.empty()) {
        summary.notes.push_back("Driving was generally steady with no strong warning signals.");
    }

    if (peakThrottle >= 70.0) {
        summary.notes.push_back("Throttle input reached a high peak during the drive.");
    }

    return summary;
}

std::string buildHumanReport(const TripSummary& summary) {
    std::ostringstream out;
    out << "DriveSense Trip Report\n";
    out << "----------------------\n";
    out << "Distance: " << formatDouble(summary.totalDistanceMiles) << " miles\n";
    out << "Duration: " << formatDouble(summary.durationMinutes) << " minutes\n";
    out << "Average speed: " << formatDouble(summary.averageSpeedMph) << " mph\n";
    out << "Max speed: " << formatDouble(summary.maxSpeedMph) << " mph\n";
    out << "Idle time: " << formatDouble(summary.idleMinutes) << " minutes\n";
    out << "Estimated fuel used: " << formatDouble(summary.fuelUsedGallons, 2) << " gallons\n";
    out << "Estimated efficiency: " << formatDouble(summary.estimatedMpg) << " mpg\n";
    out << "Hard brakes: " << summary.hardBrakeEvents << "\n";
    out << "Rapid accelerations: " << summary.rapidAccelEvents << "\n";
    out << "Stop-and-go moments: " << summary.stopAndGoMoments << "\n";
    out << "Trip score: " << formatDouble(summary.tripScore, 0) << "/100\n";
    out << "Smoothness score: " << formatDouble(summary.smoothnessScore, 0) << "/100\n";
    out << "Efficiency score: " << formatDouble(summary.efficiencyScore, 0) << "/100\n";
    out << "Peak engine temperature: " << formatDouble(summary.maxEngineTempC) << " C\n\n";
    out << "Driving Notes:\n";
    for (const std::string& note : summary.notes) {
        out << "- " << note << "\n";
    }
    return out.str();
}

std::string buildAiPrompt(const TripSummary& summary) {
    std::ostringstream out;
    out << "Summarize this vehicle trip in clear, concise language. ";
    out << "Comment on smoothness, efficiency, and possible concerns.\n\n";
    out << "Trip distance: " << formatDouble(summary.totalDistanceMiles) << " miles\n";
    out << "Trip duration: " << formatDouble(summary.durationMinutes) << " minutes\n";
    out << "Average speed: " << formatDouble(summary.averageSpeedMph) << " mph\n";
    out << "Maximum speed: " << formatDouble(summary.maxSpeedMph) << " mph\n";
    out << "Idle time: " << formatDouble(summary.idleMinutes) << " minutes\n";
    out << "Estimated fuel consumed: " << formatDouble(summary.fuelUsedGallons, 2) << " gallons\n";
    out << "Estimated mpg: " << formatDouble(summary.estimatedMpg) << "\n";
    out << "Hard braking events: " << summary.hardBrakeEvents << "\n";
    out << "Rapid acceleration events: " << summary.rapidAccelEvents << "\n";
    out << "Stop-and-go moments: " << summary.stopAndGoMoments << "\n";
    out << "Speeding moments: " << summary.speedingMoments << "\n";
    out << "Smoothness score: " << formatDouble(summary.smoothnessScore, 0) << "/100\n";
    out << "Efficiency score: " << formatDouble(summary.efficiencyScore, 0) << "/100\n";
    out << "Trip score: " << formatDouble(summary.tripScore, 0) << "/100\n";
    out << "Peak engine temperature: " << formatDouble(summary.maxEngineTempC) << " C\n";
    return out.str();
}
