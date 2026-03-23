#pragma once

#include <string>
#include <vector>

struct TripPoint {
    double timeSeconds {};
    double speedMph {};
    double rpm {};
    double fuelGallons {};
    double engineTempC {};
    double throttlePercent {};
    double brakePercent {};
};

struct TripSummary {
    double totalDistanceMiles {};
    double durationMinutes {};
    double averageSpeedMph {};
    double maxSpeedMph {};
    double idleMinutes {};
    double fuelUsedGallons {};
    double estimatedMpg {};
    double maxEngineTempC {};
    int hardBrakeEvents {};
    int rapidAccelEvents {};
    int stopAndGoMoments {};
    int speedingMoments {};
    double smoothnessScore {};
    double efficiencyScore {};
    double tripScore {};
    std::vector<std::string> notes;
};
