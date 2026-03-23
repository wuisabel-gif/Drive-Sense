const trips = [
  {
    id: "commute",
    title: "Evening Commute",
    when: "March 22, 6:10 PM",
    distance: "14.2 mi",
    duration: "31 min",
    averageSpeed: "27.5 mph",
    topSpeed: "58 mph",
    stoppedTime: "5.0 min",
    hardBrakes: 3,
    rapidAccels: 2,
    tripScore: 82,
    quality: "Smooth",
    teaser: "Moderate stop-and-go traffic with a mostly steady business commute and clean mileage capture.",
    tripSummary:
      "This trip covered 14.2 business miles in 31 minutes with moderate city traffic. The route was captured cleanly for mileage tracking, and driving was generally smooth, though three hard braking events and two rapid accelerations suggest a few rushed moments in traffic. Overall efficiency looked fair, and reducing stop-heavy idle time would likely improve both trip quality and operating costs."
  },
  {
    id: "airport",
    title: "Airport Drop-Off",
    when: "March 21, 8:05 AM",
    distance: "22.8 mi",
    duration: "39 min",
    averageSpeed: "35.0 mph",
    topSpeed: "66 mph",
    stoppedTime: "3.0 min",
    hardBrakes: 1,
    rapidAccels: 4,
    tripScore: 76,
    quality: "Energetic",
    teaser: "Faster highway-style client run with stronger acceleration patterns.",
    tripSummary:
      "This highway trip logged 22.8 business miles in 39 minutes, which is useful for clean tax-time reporting. Highway pacing helped keep stopped time low, but four rapid accelerations suggest a more aggressive driving style than usual. The trip remained controlled overall, though smoother throttle use could improve comfort, efficiency, and vehicle wear."
  },
  {
    id: "lunch",
    title: "Lunch Errand",
    when: "March 20, 12:26 PM",
    distance: "6.4 mi",
    duration: "19 min",
    averageSpeed: "18.9 mph",
    topSpeed: "41 mph",
    stoppedTime: "6.0 min",
    hardBrakes: 2,
    rapidAccels: 1,
    tripScore: 71,
    quality: "Stop-heavy",
    teaser: "Short urban work errand with frequent stops and dense intersections.",
    tripSummary:
      "This short work errand covered 6.4 business miles in 19 minutes and spent a noticeable portion of the trip stopped in traffic or at lights. Two hard braking events indicate some late slowing in urban conditions. The mileage record is still useful for business income tax reporting, and anticipating stops earlier would make the trip feel smoother."
  }
];

const tripList = document.getElementById("trip-list");

const heroTripTitle = document.getElementById("hero-trip-title");
const heroTripSummary = document.getElementById("hero-trip-summary");
const tripScoreBadge = document.getElementById("trip-score-badge");
const distanceValue = document.getElementById("distance-value");
const durationValue = document.getElementById("duration-value");
const avgSpeedValue = document.getElementById("avg-speed-value");
const stoppedValue = document.getElementById("stopped-value");
const tripSummary = document.getElementById("trip-summary");
const brakesValue = document.getElementById("brakes-value");
const accelsValue = document.getElementById("accels-value");
const topSpeedValue = document.getElementById("top-speed-value");
const qualityLabel = document.getElementById("quality-label");

function renderTripOptions() {
  trips.forEach((trip, index) => {
    const button = document.createElement("button");
    button.className = `trip-option${index === 0 ? " active" : ""}`;
    button.type = "button";
    button.dataset.tripId = trip.id;
    button.innerHTML = `
      <strong>${trip.title}</strong>
      <span>${trip.when} · ${trip.distance} · ${trip.tripScore}/100</span>
    `;
    button.addEventListener("click", () => {
      document.querySelectorAll(".trip-option").forEach((element) => {
        element.classList.remove("active");
      });
      button.classList.add("active");
      updatePhone(trip);
    });
    tripList.appendChild(button);
  });
}

function updatePhone(trip) {
  heroTripTitle.textContent = trip.title;
  heroTripSummary.textContent = trip.teaser;
  tripScoreBadge.textContent = trip.tripScore;
  distanceValue.textContent = trip.distance;
  durationValue.textContent = trip.duration;
  avgSpeedValue.textContent = trip.averageSpeed;
  stoppedValue.textContent = trip.stoppedTime;
  tripSummary.textContent = trip.tripSummary;
  brakesValue.textContent = trip.hardBrakes;
  accelsValue.textContent = trip.rapidAccels;
  topSpeedValue.textContent = trip.topSpeed;
  qualityLabel.textContent = trip.quality;
}

renderTripOptions();
updatePhone(trips[0]);
