import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var connectionStatus: String = "Desconectado"
    @Published var sensorData: SensorData?
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        discoveredDevices.removeAll()
        isScanning = true
        connectionStatus = "Procurando dispositivos..."
        
        // Escaneia APENAS dispositivos reais
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
        
        // Para o scan após 15 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.stopScanning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
        
        if discoveredDevices.isEmpty && connectedDevice == nil {
            connectionStatus = "Nenhum dispositivo encontrado"
        } else if connectedDevice != nil {
            connectionStatus = "Conectado"
        } else {
            connectionStatus = "Bluetooth pronto"
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectionStatus = "Conectando..."
        centralManager.connect(peripheral, options: nil)
        connectedPeripheral = peripheral
    }
    
    func disconnect() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // Simula dados do sensor para demonstração
    func simulateSensorData() {
        let data = SensorData(
            temperature: Double.random(in: 18...32),
            humidity: Double.random(in: 30...80),
            airQuality: Double.random(in: 50...400)
        )
        self.sensorData = data
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth pronto"
        case .poweredOff:
            connectionStatus = "Bluetooth desligado"
            discoveredDevices.removeAll()
        case .unauthorized:
            connectionStatus = "Bluetooth não autorizado"
        case .unsupported:
            connectionStatus = "Bluetooth não suportado"
        default:
            connectionStatus = "Bluetooth indisponível"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Filtros para garantir apenas dispositivos reais
        guard RSSI.intValue != 127 else { return } // 127 = dispositivo inválido
        guard RSSI.intValue > -95 else { return } // Sinal muito fraco
        
        // Só adiciona se tiver nome OU se for um dispositivo válido
        if peripheral.name != nil || !advertisementData.isEmpty {
            // Evita duplicatas
            if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        connectionStatus = "Conectado"
        stopScanning()
        
        // Simula dados após conectar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.simulateSensorData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Falha ao conectar"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.connectedDevice == nil {
                self.connectionStatus = "Bluetooth pronto"
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDevice = nil
        connectionStatus = "Desconectado"
        sensorData = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.connectedDevice == nil {
                self.connectionStatus = "Bluetooth pronto"
            }
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    // Aqui você implementaria a leitura de características quando tiver o hardware real
}
