import SwiftUI
import PhotosUI

struct PlantSelectionView: View {
    @State private var selectedPlant: Plant?
    @State private var showingReport = false
    @State private var showingAddPlant = false
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var plants: [Plant] = []
    @State private var lastUpdateTime = Date()
    
    let timer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header com logo
                    VStack(spacing: 20) {
                        // Logo
                        ZStack {
                            // Hexágono de fundo
                            Image(systemName: "hexagon")
                                .font(.system(size: 70))
                                .foregroundColor(.green.opacity(0.15))
                            
                            // Cacto
                            Image(systemName: "camera.macro")
                                .font(.system(size: 32, weight: .ultraLight))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 30)
                        
                        // Nome do app
                        Text("CAKTUS")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .tracking(4)
                            .foregroundColor(.white)
                        
                        // Status bar
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("SISTEMA ATIVO")
                                    .font(.system(size: 10, weight: .medium))
                                    .tracking(1.5)
                                    .foregroundColor(.green)
                            }
                            
                            Rectangle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 1, height: 12)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 9))
                                Text("CONECTADO")
                                    .font(.system(size: 10, weight: .medium))
                                    .tracking(1.5)
                            }
                            .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.05))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.bottom, 30)
                    
                    // Toolbar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MONITORAMENTO")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("\(plants.count) \(plants.count == 1 ? "planta" : "plantas")")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingAddPlant = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("NOVA")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.green)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Lista de plantas
                    if plants.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Grid de pontos decorativo
                            ZStack {
                                ForEach(0..<3, id: \.self) { row in
                                    ForEach(0..<3, id: \.self) { col in
                                        Circle()
                                            .fill(.white.opacity(0.05))
                                            .frame(width: 4, height: 4)
                                            .offset(x: CGFloat(col - 1) * 40, y: CGFloat(row - 1) * 40)
                                    }
                                }
                            }
                            
                            VStack(spacing: 12) {
                                Text("NENHUMA PLANTA")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(.white.opacity(0.3))
                                
                                Text("Adicione sua primeira planta\npara começar o monitoramento")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Button(action: { showingAddPlant = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                    Text("ADICIONAR PLANTA")
                                        .font(.system(size: 12, weight: .bold))
                                        .tracking(1.5)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(.green)
                                )
                            }
                            .padding(.top, 8)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 1) {
                                ForEach(Array(plants.enumerated()), id: \.element.id) { index, plant in
                                    PlantRowTech(
                                        plant: plant,
                                        index: index + 1,
                                        sensorData: SensorData(
                                            temperature: Double.random(in: 18...30),
                                            humidity: Double.random(in: 35...75),
                                            airQuality: Double.random(in: 50...150)
                                        )
                                    ) {
                                        selectedPlant = plant
                                        bluetoothManager.simulateSensorData()
                                        showingReport = true
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(.white.opacity(0.03))
                            )
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView(plants: $plants)
            }
            .sheet(isPresented: $showingReport) {
                if let plant = selectedPlant {
                    PlantReportView(
                        plant: plant,
                        sensorData: bluetoothManager.sensorData ?? SensorData(
                            temperature: Double.random(in: 18...30),
                            humidity: Double.random(in: 35...75),
                            airQuality: Double.random(in: 50...150)
                        ),
                        isPresented: $showingReport
                    )
                }
            }
            .onAppear {
                loadInitialPlants()
            }
            .onReceive(timer) { _ in
                bluetoothManager.simulateSensorData()
                lastUpdateTime = Date()
            }
        }
    }
    
    func loadInitialPlants() {
        if plants.isEmpty {
            plants = [
                Plant(
                    name: "Samambaia",
                    species: "Nephrolepis exaltata",
                    imageName: "leaf.fill",
                    idealConditions: PlantConditions(
                        minTemperature: 18, maxTemperature: 24,
                        minHumidity: 60, maxHumidity: 80,
                        minAirQuality: 0, maxAirQuality: 100
                    )
                ),
                Plant(
                    name: "Suculenta",
                    species: "Crassula ovata",
                    imageName: "leaf.circle.fill",
                    idealConditions: PlantConditions(
                        minTemperature: 15, maxTemperature: 24,
                        minHumidity: 30, maxHumidity: 50,
                        minAirQuality: 0, maxAirQuality: 150
                    )
                ),
                Plant(
                    name: "Orquídea",
                    species: "Phalaenopsis",
                    imageName: "flame.fill",
                    idealConditions: PlantConditions(
                        minTemperature: 20, maxTemperature: 28,
                        minHumidity: 50, maxHumidity: 70,
                        minAirQuality: 0, maxAirQuality: 80
                    )
                )
            ]
        }
    }
}

struct PlantRowTech: View {
    let plant: Plant
    let index: Int
    let sensorData: SensorData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Número
                Text(String(format: "%02d", index))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 50)
                
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                
                // Ícone
                Image(systemName: plant.imageName)
                    .font(.system(size: 18, weight: .ultraLight))
                    .foregroundColor(.green)
                    .frame(width: 60)
                
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(plant.name.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white)
                    
                    Text(plant.species)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                // Status indicator
                VStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    
                    Text("OK")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(.green)
                }
                .padding(.trailing, 20)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.trailing, 20)
            }
            .frame(height: 70)
            .background(Color.clear)
            .overlay(
                Rectangle()
                    .fill(.white.opacity(0.05))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

import SwiftUI
import PhotosUI

struct AddPlantView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var plants: [Plant]
    
    @State private var plantName = ""
    @State private var selectedType: PlantType = .custom
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var customPlantName = ""
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var aiSearchResult: PlantSearchResult?
    
    private let groqService = GroqAIService()
    
    enum PlantType: String, CaseIterable {
        case custom = "Buscar com IA"
        case fern = "Samambaia"
        case succulent = "Suculenta"
        case orchid = "Orquídea"
        case cactus = "Cacto"
        case monstera = "Monstera"
        case snake = "Espada de São Jorge"
        
        var species: String {
            switch self {
            case .custom: return ""
            case .fern: return "Nephrolepis exaltata"
            case .succulent: return "Crassula ovata"
            case .orchid: return "Phalaenopsis"
            case .cactus: return "Cactaceae"
            case .monstera: return "Monstera deliciosa"
            case .snake: return "Sansevieria trifasciata"
            }
        }
        
        var icon: String {
            switch self {
            case .custom: return "sparkles"
            case .fern: return "leaf.fill"
            case .succulent: return "leaf.circle.fill"
            case .orchid: return "flame.fill"
            case .cactus: return "drop.fill"
            case .monstera: return "tree.fill"
            case .snake: return "bolt.fill"
            }
        }
        
        var conditions: PlantConditions? {
            switch self {
            case .custom: return nil
            case .fern:
                return PlantConditions(minTemperature: 18, maxTemperature: 24, minHumidity: 60, maxHumidity: 80, minAirQuality: 0, maxAirQuality: 100)
            case .succulent:
                return PlantConditions(minTemperature: 15, maxTemperature: 24, minHumidity: 30, maxHumidity: 50, minAirQuality: 0, maxAirQuality: 150)
            case .orchid:
                return PlantConditions(minTemperature: 20, maxTemperature: 28, minHumidity: 50, maxHumidity: 70, minAirQuality: 0, maxAirQuality: 80)
            case .cactus:
                return PlantConditions(minTemperature: 18, maxTemperature: 30, minHumidity: 20, maxHumidity: 40, minAirQuality: 0, maxAirQuality: 200)
            case .monstera:
                return PlantConditions(minTemperature: 18, maxTemperature: 27, minHumidity: 50, maxHumidity: 70, minAirQuality: 0, maxAirQuality: 100)
            case .snake:
                return PlantConditions(minTemperature: 15, maxTemperature: 29, minHumidity: 30, maxHumidity: 50, minAirQuality: 0, maxAirQuality: 150)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("ADICIONAR")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(3)
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("Nova Planta")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            // Foto
                            VStack(spacing: 12) {
                                HStack {
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: 3, height: 14)
                                    Text("IMAGEM")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    ZStack {
                                        Rectangle()
                                            .fill(.white.opacity(0.03))
                                            .overlay(
                                                Rectangle()
                                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                    .foregroundColor(.white.opacity(0.2))
                                            )
                                            .frame(height: 180)
                                        
                                        if let selectedImage {
                                            Image(uiImage: selectedImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 180)
                                                .clipped()
                                        } else {
                                            VStack(spacing: 10) {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 32, weight: .ultraLight))
                                                    .foregroundColor(.white.opacity(0.3))
                                                Text("ADICIONAR FOTO")
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .tracking(2)
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                    }
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            if let uiImage = UIImage(data: data) {
                                                selectedImage = uiImage
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Nome
                            VStack(spacing: 12) {
                                HStack {
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: 3, height: 14)
                                    Text("IDENTIFICAÇÃO")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                TextField("", text: $plantName, prompt: Text("Nome da planta").foregroundColor(.white.opacity(0.3)))
                                    .font(.system(size: 16, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .background(
                                        Rectangle()
                                            .fill(.white.opacity(0.03))
                                            .overlay(
                                                Rectangle()
                                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Tipo
                            VStack(spacing: 12) {
                                HStack {
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: 3, height: 14)
                                    Text("ESPÉCIE")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                VStack(spacing: 1) {
                                    ForEach(PlantType.allCases, id: \.self) { type in
                                        PlantTypeRowTech(
                                            type: type,
                                            isSelected: selectedType == type
                                        ) {
                                            selectedType = type
                                            if type != .custom {
                                                aiSearchResult = nil
                                                searchError = nil
                                            }
                                        }
                                    }
                                }
                                .background(
                                    Rectangle()
                                        .fill(.white.opacity(0.03))
                                        .overlay(
                                            Rectangle()
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Campo de busca personalizada
                            if selectedType == .custom {
                                VStack(spacing: 16) {
                                    HStack {
                                        Rectangle()
                                            .fill(.green)
                                            .frame(width: 3, height: 14)
                                        Text("BUSCAR PLANTA")
                                            .font(.system(size: 11, weight: .bold))
                                            .tracking(2)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 12) {
                                        TextField("", text: $customPlantName, prompt: Text("Ex: Rosa, Lírio, Violeta...").foregroundColor(.white.opacity(0.3)))
                                            .font(.system(size: 16, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(16)
                                            .background(
                                                Rectangle()
                                                    .fill(.white.opacity(0.03))
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(.white.opacity(0.1), lineWidth: 1)
                                                    )
                                            )
                                        
                                        Button(action: searchPlant) {
                                            Group {
                                                if isSearching {
                                                    ProgressView()
                                                        .tint(.green)
                                                } else {
                                                    Image(systemName: "magnifyingglass")
                                                        .font(.system(size: 16, weight: .semibold))
                                                }
                                            }
                                            .foregroundColor(.black)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                Rectangle()
                                                    .fill(customPlantName.isEmpty ? .white.opacity(0.1) : .green)
                                            )
                                        }
                                        .disabled(customPlantName.isEmpty || isSearching)
                                    }
                                    
                                    // Resultado da busca
                                    if let result = aiSearchResult {
                                        VStack(spacing: 12) {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                Text("Planta encontrada!")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.green)
                                                Spacer()
                                            }
                                            
                                            VStack(spacing: 8) {
                                                InfoRow(label: "ESPÉCIE", value: result.species)
                                                InfoRow(label: "TEMPERATURA", value: "\(Int(result.minTemperature))°C - \(Int(result.maxTemperature))°C")
                                                InfoRow(label: "UMIDADE", value: "\(Int(result.minHumidity))% - \(Int(result.maxHumidity))%")
                                            }
                                            .padding(12)
                                            .background(
                                                Rectangle()
                                                    .fill(.green.opacity(0.05))
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(.green.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    // Erro
                                    if let error = searchError {
                                        HStack(spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.orange)
                                            Text(error)
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            Rectangle()
                                                .fill(.orange.opacity(0.1))
                                                .overlay(
                                                    Rectangle()
                                                        .stroke(.orange.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(20)
                    }
                }
                
                // Botão fixo
                VStack {
                    Spacer()
                    
                    Button(action: addPlant) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                            Text("CONFIRMAR")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(2)
                        }
                        .foregroundColor(canAddPlant ? .black : .white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Rectangle()
                                .fill(canAddPlant ? .green : .white.opacity(0.05))
                        )
                    }
                    .disabled(!canAddPlant)
                    .padding(20)
                    .background(
                        Rectangle()
                            .fill(.black)
                            .shadow(color: .black.opacity(0.5), radius: 30, y: -10)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text("FECHAR")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }
    
    var canAddPlant: Bool {
        if plantName.isEmpty { return false }
        if selectedType == .custom {
            return aiSearchResult != nil
        }
        return true
    }
    
    func searchPlant() {
        isSearching = true
        searchError = nil
        aiSearchResult = nil
        
        Task {
            do {
                let result = try await groqService.searchPlantInfo(plantName: customPlantName)
                await MainActor.run {
                    self.aiSearchResult = result
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.searchError = "Não foi possível encontrar informações sobre esta planta. Tente outro nome."
                    self.isSearching = false
                }
            }
        }
    }
    
    func addPlant() {
        let conditions: PlantConditions
        let species: String
        let icon: String
        
        if selectedType == .custom, let result = aiSearchResult {
            conditions = PlantConditions(
                minTemperature: result.minTemperature,
                maxTemperature: result.maxTemperature,
                minHumidity: result.minHumidity,
                maxHumidity: result.maxHumidity,
                minAirQuality: result.minAirQuality,
                maxAirQuality: result.maxAirQuality
            )
            species = result.species
            icon = result.icon
        } else {
            conditions = selectedType.conditions!
            species = selectedType.species
            icon = selectedType.icon
        }
        
        let newPlant = Plant(
            name: plantName,
            species: species,
            imageName: icon,
            idealConditions: conditions
        )
        plants.append(newPlant)
        dismiss()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct PlantTypeRowTech: View {
    let type: AddPlantView.PlantType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .ultraLight))
                    .foregroundColor(isSelected ? .green : .white.opacity(0.4))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    
                    if type != .custom {
                        Text(type.species)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    } else {
                        Text("Use IA para buscar qualquer planta")
                            .font(.system(size: 9))
                            .foregroundColor(.green.opacity(0.6))
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(16)
            .background(isSelected ? Color.green.opacity(0.05) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(.white.opacity(0.05))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TechButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
