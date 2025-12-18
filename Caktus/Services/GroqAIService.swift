import Foundation

    struct PlantSearchResult: Codable {
        let species: String
        let icon: String
        let minTemperature: Double
        let maxTemperature: Double
        let minHumidity: Double
        let maxHumidity: Double
        let minAirQuality: Double
        let maxAirQuality: Double
    }

    class GroqAIService {
        // SUBSTITUA PELA SUA API KEY DO GROQ
        private let apiKey = "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"
        private let apiURL = "https://api.groq.com/openai/v1/chat/completions"
        
        func generatePlantReport(plant: Plant, sensorData: SensorData) async throws -> String {
            let prompt = """
            Você é um especialista em plantas. Analise os dados do sensor para a planta \(plant.name) (\(plant.species)).
            
            Condições ideais:
            - Temperatura: \(plant.idealConditions.minTemperature)°C - \(plant.idealConditions.maxTemperature)°C
            - Umidade: \(plant.idealConditions.minHumidity)% - \(plant.idealConditions.maxHumidity)%
            - Qualidade do ar: \(plant.idealConditions.minAirQuality) - \(plant.idealConditions.maxAirQuality) AQI
            
            Condições atuais:
            - Temperatura: \(String(format: "%.1f", sensorData.temperature))°C
            - Umidade: \(String(format: "%.1f", sensorData.humidity))%
            - Qualidade do ar: \(String(format: "%.0f", sensorData.airQuality)) AQI
            
            Gere um relatório OBJETIVO e BREVE seguindo estas regras:
            
            1. Use **texto entre asteriscos duplos** para DESTACAR as informações mais importantes (diagnóstico principal, ações críticas)
            2. Seja DIRETO: máximo 4-5 frases curtas
            3. Foque APENAS no que é essencial
            4. Use • para listar recomendações práticas (máximo 3 itens)
            5. Use emojis relevantes: 🌡️ 💧 🌱 ⚠️ ✅ quando apropriado
            
            Formato exemplo:
            **Status Geral**: [diagnóstico em 1 frase]
            
            [1 frase sobre temperatura se relevante]
            [1 frase sobre umidade se relevante]
            [1 frase sobre ar se relevante]
            
            **Ações recomendadas:**
            • [ação 1]
            • [ação 2]
            • [ação 3]
            
            Seja objetivo, técnico mas amigável.
            """
            
            let requestBody: [String: Any] = [
                "model": "llama-3.3-70b-versatile",
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "temperature": 0.7,
                "max_tokens": 400
            ]
            
            guard let url = URL(string: apiURL) else {
                throw NSError(domain: "Invalid URL", code: 0)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "API Error", code: 0)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = json?["choices"] as? [[String: Any]]
            let message = choices?.first?["message"] as? [String: Any]
            let content = message?["content"] as? String
            
            return content ?? "Não foi possível gerar o relatório."
        }
        
        func searchPlantInfo(plantName: String) async throws -> PlantSearchResult {
            let prompt = """
            Você é um botânico especialista. Busque informações sobre a planta: "\(plantName)"
            
            Retorne APENAS um JSON válido (sem markdown, sem ```json) com esta estrutura:
            {
              "species": "nome científico completo",
              "icon": "escolha o ícone SF Symbol mais apropriado entre: leaf.fill, leaf.circle.fill, flame.fill, drop.fill, tree.fill, bolt.fill, camera.macro, cloud.fill",
              "minTemperature": número (temperatura mínima ideal em °C),
              "maxTemperature": número (temperatura máxima ideal em °C),
              "minHumidity": número (umidade mínima ideal em %),
              "maxHumidity": número (umidade máxima ideal em %),
              "minAirQuality": número (geralmente 0),
              "maxAirQuality": número (AQI máximo ideal, geralmente entre 50-150)
            }
            
            Se não conhecer a planta, use valores padrões razoáveis: temp 18-26°C, umidade 40-70%, aqi 0-100.
            
            IMPORTANTE: Retorne SOMENTE o JSON, nada mais.
            """
            
            let requestBody: [String: Any] = [
                "model": "llama-3.3-70b-versatile",
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "temperature": 0.3,
                "max_tokens": 300
            ]
            
            guard let url = URL(string: apiURL) else {
                throw NSError(domain: "Invalid URL", code: 0)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "API Error", code: 0)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = json?["choices"] as? [[String: Any]]
            let message = choices?.first?["message"] as? [String: Any]
            guard let content = message?["content"] as? String else {
                throw NSError(domain: "No content", code: 0)
            }
            
            // Remove markdown code blocks se existirem
            let cleanedContent = content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse JSON
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                throw NSError(domain: "Invalid JSON data", code: 0)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(PlantSearchResult.self, from: jsonData)
            
            return result
        }
    }
