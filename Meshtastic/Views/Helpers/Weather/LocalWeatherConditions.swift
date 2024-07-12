//
//  LocalWeatherConditions.swift
//  Meshtastic
//
//  Created by Garth Vander Houwen on 7/9/24.
//
import SwiftUI
import MapKit
import WeatherKit
import OSLog

struct LocalWeatherConditions: View {
	private let gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
	@State var location: CLLocation?
	/// Weather
	/// The current weather condition for the city.
	@State private var condition: WeatherCondition?
	@State private var temperature: String = ""
	@State private var dewPoint: String = ""
	@State private var humidity: Int?
	@State private var pressure: Measurement<UnitPressure>?
	@State private var windSpeed: String = ""
	@State private var windGust: String = ""
	@State private var windDirection: Measurement<UnitAngle>?
	@State private var windCompassDirection: String = ""
	@State private var symbolName: String = "cloud.fill"
	@State private var attributionLink: URL?
	@State private var attributionLogo: URL?

	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var body: some View {
		if location != nil {
			VStack {
				LazyVGrid(columns: gridItemLayout) {
					WeatherConditionsCompactWidget(temperature: temperature, symbolName: symbolName, description: condition?.description.uppercased() ?? "??")
					HumidityCompactWidget(humidity: humidity ?? 0, dewPoint: dewPoint)
					PressureCompactWidget(pressure: String(pressure?.value ?? 0.0 / 100), unit: pressure?.unit.symbol ?? "??")
					WindCompactWidget(speed: windSpeed, gust: windGust, direction: windCompassDirection)
				}
			}
			.task {
				do {
					if location != nil {
						let weather = try await WeatherService.shared.weather(for: location!)
						let numFormatter = NumberFormatter()
						let measurementFormatter = MeasurementFormatter()
						numFormatter.maximumFractionDigits = 0
						measurementFormatter.numberFormatter = numFormatter
						measurementFormatter.unitStyle = .short
						measurementFormatter.locale = Locale.current
						condition = weather.currentWeather.condition
						temperature = measurementFormatter.string(from: weather.currentWeather.temperature)
						dewPoint = measurementFormatter.string(from: weather.currentWeather.dewPoint)
						humidity = Int(weather.currentWeather.humidity * 100)
						pressure = weather.currentWeather.pressure
						windSpeed = measurementFormatter.string(from: weather.currentWeather.wind.speed)//weather.currentWeather.wind.speed
						windGust = measurementFormatter.string(from: weather.currentWeather.wind.gust ?? Measurement(value: 0.0, unit: weather.currentWeather.wind.gust!.unit))
						windDirection = weather.currentWeather.wind.direction
						windCompassDirection = weather.currentWeather.wind.compassDirection.description
						symbolName = weather.currentWeather.symbolName
						let attribution = try await WeatherService.shared.attribution
						attributionLink = attribution.legalPageURL
						attributionLogo = colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL
					}
				} catch {
					Logger.services.error("Could not gather weather information: \(error.localizedDescription)")
					condition = .clear
					symbolName = "cloud.fill"
				}
			}
			VStack {
				HStack {
					AsyncImage(url: attributionLogo) { image in
						image
							.resizable()
							.scaledToFit()
					} placeholder: {
						ProgressView()
							.controlSize(.mini)
					}
					.frame(height: 10)
					Link("Other data sources", destination: attributionLink ?? URL(string: "https://weather-data.apple.com/legal-attribution.html")!)
						.font(.caption2)
				}
				.padding(2)
			}
		}
	}
}

struct WeatherConditionsCompactWidget: View {
	let temperature: String
	let symbolName: String
	let description: String
	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack(alignment: .leading) {
				Label { Text(description) } icon: { Image(systemName: symbolName).symbolRenderingMode(.multicolor) }
					.font(.caption)
				Text(temperature)
					.font(.system(size: 90))
			}
			.frame(maxWidth: .infinity)
			.frame(height: 175)
			.background(.tertiary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
	}
}

struct HumidityCompactWidget: View {
	let humidity: Int
	let dewPoint: String
	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack(alignment: .leading) {
				Label { Text("HUMIDITY") } icon: { Image(systemName: "humidity").symbolRenderingMode(.multicolor) }
					.font(.caption)
				Text("\(humidity)%")
					.font(.largeTitle)
					.padding(.bottom)
				Text("The dew point is \(dewPoint) right now.")
					.lineLimit(3)
					.fixedSize(horizontal: false, vertical: true)
					.font(.caption)
			}
			.padding(.horizontal)
			.frame(maxWidth: .infinity)
			.frame(height: 175)
			.background(.tertiary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
	}
}

struct PressureCompactWidget: View {
	let pressure: String
	let unit: String
	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack(alignment: .leading) {
				Label { Text("PRESSURE") } icon: { Image(systemName: "gauge").symbolRenderingMode(.multicolor) }
					.font(.caption2)
				Text(pressure)
					.font(.system(size: 35))
					.padding(.bottom)
				Text(unit)
					.padding(.top)
			}
			.padding(.horizontal)
			.frame(maxWidth: .infinity)
			.frame(height: 175)
			.background(.tertiary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
	}
}


struct WindCompactWidget: View {
	let speed: String
	let gust: String
	let direction: String
	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack(alignment: .leading) {
				Label { Text("WIND") } icon: { Image(systemName: "wind").foregroundColor(.accentColor) }
					.font(.caption)
				Text("\(direction)")
					.font(.caption)
					.padding(.bottom, 10)
				Text(speed)
					.font(.system(size: 35))
				Text("Gusts \(gust)")
			}
			.padding(.horizontal)
			.frame(maxWidth: .infinity)
			.frame(height: 175)
			.background(.tertiary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
	}
}

