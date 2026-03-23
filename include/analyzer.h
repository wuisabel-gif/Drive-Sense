#pragma once

#include "trip_types.h"

#include <vector>

TripSummary analyzeTrip(const std::vector<TripPoint>& points);
std::string buildHumanReport(const TripSummary& summary);
std::string buildAiPrompt(const TripSummary& summary);
