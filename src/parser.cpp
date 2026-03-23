#include "parser.h"

#include <fstream>
#include <sstream>
#include <stdexcept>

namespace {
double parseDouble(const std::string& value, const std::string& fieldName, int lineNumber) {
    try {
        size_t index = 0;
        const double parsed = std::stod(value, &index);
        if (index != value.size()) {
            throw std::runtime_error("extra characters");
        }
        return parsed;
    } catch (const std::exception&) {
        throw std::runtime_error("Invalid numeric value for " + fieldName + " on line " +
                                 std::to_string(lineNumber));
    }
}
}

std::vector<TripPoint> parseTripCsv(const std::string& filePath) {
    std::ifstream input(filePath);
    if (!input) {
        throw std::runtime_error("Could not open CSV file: " + filePath);
    }

    std::vector<TripPoint> points;
    std::string line;

    if (!std::getline(input, line)) {
        throw std::runtime_error("CSV file is empty: " + filePath);
    }

    int lineNumber = 1;
    while (std::getline(input, line)) {
        ++lineNumber;
        if (line.empty()) {
            continue;
        }

        std::stringstream lineStream(line);
        std::string cell;
        std::vector<std::string> columns;

        while (std::getline(lineStream, cell, ',')) {
            columns.push_back(cell);
        }

        if (columns.size() != 7) {
            throw std::runtime_error("Expected 7 columns on line " + std::to_string(lineNumber));
        }

        TripPoint point;
        point.timeSeconds = parseDouble(columns[0], "time", lineNumber);
        point.speedMph = parseDouble(columns[1], "speed_mph", lineNumber);
        point.rpm = parseDouble(columns[2], "rpm", lineNumber);
        point.fuelGallons = parseDouble(columns[3], "fuel_level", lineNumber);
        point.engineTempC = parseDouble(columns[4], "temp", lineNumber);
        point.throttlePercent = parseDouble(columns[5], "throttle", lineNumber);
        point.brakePercent = parseDouble(columns[6], "brake", lineNumber);

        points.push_back(point);
    }

    if (points.size() < 2) {
        throw std::runtime_error("Need at least two trip points to analyze a trip");
    }

    return points;
}
