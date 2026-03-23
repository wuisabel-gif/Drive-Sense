#pragma once

#include "trip_types.h"

#include <string>
#include <vector>

std::vector<TripPoint> parseTripCsv(const std::string& filePath);
