#include "analyzer.h"
#include "parser.h"

#include <exception>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    const std::string defaultPath = "data/sample_trip.csv";
    const std::string filePath = argc > 1 ? argv[1] : defaultPath;

    try {
        const std::vector<TripPoint> points = parseTripCsv(filePath);
        const TripSummary summary = analyzeTrip(points);

        std::cout << buildHumanReport(summary) << "\n";
        std::cout << "AI Prompt Seed\n";
        std::cout << "--------------\n";
        std::cout << buildAiPrompt(summary) << "\n";
    } catch (const std::exception& error) {
        std::cerr << "Error: " << error.what() << '\n';
        return 1;
    }

    return 0;
}
