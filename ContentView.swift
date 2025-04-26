import SwiftUI

struct WeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
    struct Weather: Codable {
        let icon: String
        let description: String
    }
    let main: Main
    let weather: [Weather]
}

struct ContentView: View {
    @State private var city: String = ""
    @State private var temperature: String = "--"
    @State private var humidity: String = "--"
    @State private var weatherIcon: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Text("Weather App")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                        TextField("Enter city", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        fetchWeather()
                    }) {
                        Text("Get Weather")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    } else {
                        VStack(spacing: 20) {
                            if !weatherIcon.isEmpty {
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherIcon)@4x.png")) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 150, height: 150)
                            }

                            Text("Temperature: \(temperature) °C")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)

                            Text("Humidity: \(humidity) %")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
        }
    }

    func fetchWeather() {
        let apiKey = "f58266ccbe8f2a8ad2db067f6843bee5" // User provided OpenWeatherMap API key
        let cityEscaped = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard !cityEscaped.isEmpty else {
            errorMessage = "Please enter a city name."
            return
        }
        errorMessage = nil
        temperature = "--"
        humidity = "--"
        weatherIcon = ""
        isLoading = true

        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEscaped)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received."
                }
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    temperature = String(format: "%.1f", weatherResponse.main.temp)
                    humidity = "\(weatherResponse.main.humidity)"
                    weatherIcon = weatherResponse.weather.first?.icon ?? ""
                    errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode weather data."
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
