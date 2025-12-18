import SwiftUI

struct PlantReportView: View {
    let plant: Plant
    let sensorData: SensorData
    @Binding var isPresented: Bool
    
    @State private var report: String = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedSensor: SensorType?
    @State private var hasGeneratedReport = false
    
    private let groqService = GroqAIService()
    
    enum SensorType {
        case temperature, humidity, airQuality
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header compacto
                        HStack(spacing: 16) {
                            Image(systemName: plant.imageName)
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.green)
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plant.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(plant.species)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Sensores
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("SENSORES")
                                    .font(.system(size: 11, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                            
                            VStack(spacing: 1) {
                                SensorRowTech(
                                    icon: "thermometer",
                                    label: "TEMPERATURA",
                                    value: String(format: "%.1f°C", sensorData.temperature),
                                    color: getTemperatureColor(),
                                    isExpanded: selectedSensor == .temperature
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedSensor = selectedSensor == .temperature ? nil : .temperature
                                    }
                                }
                                
                                if selectedSensor == .temperature {
                                    DetailRowTech(
                                        ideal: "\(Int(plant.idealConditions.minTemperature))°C - \(Int(plant.idealConditions.maxTemperature))°C",
                                        difference: getTemperatureDifference(),
                                        color: getTemperatureColor()
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)
                                    ))
                                }
                                
                                SensorRowTech(
                                    icon: "humidity",
                                    label: "UMIDADE",
                                    value: String(format: "%.0f%%", sensorData.humidity),
                                    color: getHumidityColor(),
                                    isExpanded: selectedSensor == .humidity
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedSensor = selectedSensor == .humidity ? nil : .humidity
                                    }
                                }
                                
                                if selectedSensor == .humidity {
                                    DetailRowTech(
                                        ideal: "\(Int(plant.idealConditions.minHumidity))% - \(Int(plant.idealConditions.maxHumidity))%",
                                        difference: getHumidityDifference(),
                                        color: getHumidityColor()
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)
                                    ))
                                }
                                
                                SensorRowTech(
                                    icon: "aqi.medium",
                                    label: "QUALIDADE DO AR",
                                    value: String(format: "%.0f AQI", sensorData.airQuality),
                                    color: getAirQualityColor(),
                                    isExpanded: selectedSensor == .airQuality
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedSensor = selectedSensor == .airQuality ? nil : .airQuality
                                    }
                                }
                                
                                if selectedSensor == .airQuality {
                                    DetailRowTech(
                                        ideal: "\(Int(plant.idealConditions.minAirQuality)) - \(Int(plant.idealConditions.maxAirQuality)) AQI",
                                        difference: getAirQualityDifference(),
                                        color: getAirQualityColor()
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)
                                    ))
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Relatório IA
                        VStack(spacing: 0) {
                            HStack {
                                Text("ANÁLISE")
                                    .font(.system(size: 11, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                            
                            VStack(spacing: 20) {
                                if !hasGeneratedReport && !isLoading {
                                    // Estado inicial - botão para gerar
                                    VStack(spacing: 16) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 32, weight: .thin))
                                            .foregroundColor(.green.opacity(0.5))
                                        
                                        Text("Clique para gerar uma análise\ninteligente das condições")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.4))
                                            .multilineTextAlignment(.center)
                                        
                                        Button(action: generateReport) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 14))
                                                Text("Gerar Relatório")
                                                    .font(.system(size: 15, weight: .semibold))
                                            }
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.green)
                                            )
                                        }
                                        .padding(.top, 8)
                                    }
                                    .padding(32)
                                } else if isLoading {
                                    // Carregando
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .tint(.green)
                                            .scaleEffect(1.2)
                                        Text("Analisando dados...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(40)
                                } else if let error = error {
                                    // Erro
                                    VStack(spacing: 16) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.system(size: 32, weight: .thin))
                                            .foregroundColor(.orange.opacity(0.7))
                                        
                                        Text(error)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                        
                                        Button(action: generateReport) {
                                            Text("Tentar novamente")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding(32)
                                } else {
                                    // Relatório gerado
                                    VStack(alignment: .leading, spacing: 16) {
                                        FormattedReportTextTech(report: report)
                                        
                                        Button(action: generateReport) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "arrow.clockwise")
                                                    .font(.system(size: 12))
                                                Text("Gerar novo relatório")
                                                    .font(.system(size: 13, weight: .medium))
                                            }
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.white.opacity(0.05))
                                            )
                                        }
                                    }
                                    .padding(20)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    func generateReport() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let generatedReport = try await groqService.generatePlantReport(plant: plant, sensorData: sensorData)
                await MainActor.run {
                    self.report = generatedReport
                    self.isLoading = false
                    self.hasGeneratedReport = true
                }
            } catch {
                await MainActor.run {
                    self.error = "Erro ao gerar relatório.\nVerifique sua conexão."
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Temperature
    func getTemperatureColor() -> Color {
        let temp = sensorData.temperature
        if temp < plant.idealConditions.minTemperature { return .blue }
        if temp > plant.idealConditions.maxTemperature { return .red }
        return .green
    }
    
    func getTemperatureDifference() -> String {
        let temp = sensorData.temperature
        let min = plant.idealConditions.minTemperature
        let max = plant.idealConditions.maxTemperature
        
        if temp < min {
            return "\(String(format: "%.1f°C", min - temp)) abaixo"
        } else if temp > max {
            return "\(String(format: "%.1f°C", temp - max)) acima"
        }
        return "Ideal"
    }
    
    // MARK: - Humidity
    func getHumidityColor() -> Color {
        let h = sensorData.humidity
        if h < plant.idealConditions.minHumidity || h > plant.idealConditions.maxHumidity {
            return .orange
        }
        return .green
    }
    
    func getHumidityDifference() -> String {
        let h = sensorData.humidity
        let min = plant.idealConditions.minHumidity
        let max = plant.idealConditions.maxHumidity
        
        if h < min {
            return "\(String(format: "%.0f%%", min - h)) abaixo"
        } else if h > max {
            return "\(String(format: "%.0f%%", h - max)) acima"
        }
        return "Ideal"
    }
    
    // MARK: - Air Quality
    func getAirQualityColor() -> Color {
        if sensorData.airQuality > plant.idealConditions.maxAirQuality { return .red }
        if sensorData.airQuality > plant.idealConditions.maxAirQuality * 0.7 { return .orange }
        return .green
    }
    
    func getAirQualityDifference() -> String {
        let aqi = sensorData.airQuality
        let max = plant.idealConditions.maxAirQuality
        
        if aqi > max {
            return "\(String(format: "%.0f", aqi - max)) acima"
        }
        return "Ideal"
    }
}

// MARK: - Sensor Card Component
struct SensorRowTech: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(isExpanded ? color.opacity(0.05) : Color.clear)
        }
    }
}

// MARK: - Detail Card Component
struct DetailRowTech: View {
    let ideal: String
    let difference: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: 2)
                .padding(.leading, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Ideal:")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Text(ideal)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                    Text(difference)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(color)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.trailing, 16)
    }
}

// MARK: - Formatted Report Text Component
struct FormattedReportTextTech: View {
    let report: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(processReport(), id: \.self) { segment in
                if segment.hasPrefix("•") {
                    // Item de lista
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .font(.system(size: 14))
                            .foregroundColor(.green.opacity(0.6))
                        Text(segment.replacingOccurrences(of: "• ", with: ""))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else if !segment.isEmpty {
                    // Texto com formatação inline
                    formatTextWithBold(segment)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func formatTextWithBold(_ text: String) -> some View {
        let parts = text.components(separatedBy: "**")
        
        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                if index % 2 == 0 {
                    // Texto normal
                    Text(part)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                } else {
                    // Texto em bold/destaque
                    Text(part)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    func processReport() -> [String] {
        report.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
