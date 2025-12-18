import Foundation
import UIKit

struct Plant: Identifiable, Codable {
    let id: UUID
    let name: String
    let species: String
    let imageName: String
    let idealConditions: PlantConditions
    var imageData: Data? // Para armazenar a foto do usuário
    
    init(id: UUID = UUID(), name: String, species: String, imageName: String, idealConditions: PlantConditions, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.species = species
        self.imageName = imageName
        self.idealConditions = idealConditions
        self.imageData = imageData
    }
    
    var displayImage: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
}

struct PlantConditions: Codable {
    let minTemperature: Double
    let maxTemperature: Double
    let minHumidity: Double
    let maxHumidity: Double
    let minAirQuality: Double
    let maxAirQuality: Double
}

struct SensorData: Codable {
    let temperature: Double
    let humidity: Double
    let airQuality: Double
    let timestamp: Date
    
    init(temperature: Double, humidity: Double, airQuality: Double, timestamp: Date = Date()) {
        self.temperature = temperature
        self.humidity = humidity
        self.airQuality = airQuality
        self.timestamp = timestamp
    }
}
