import CoreBluetooth
import SwiftUI

struct BluetoothView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var isConnected: Bool
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Header tech
                VStack(spacing: 24) {
                    // Ícone animado
                    ZStack {
                        // Círculos de radar
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    bluetoothManager.isScanning ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                                .frame(width: 60 + CGFloat(index * 30), height: 60 + CGFloat(index * 30))
                                .scaleEffect(bluetoothManager.isScanning ? 1.2 : 1.0)
                                .opacity(bluetoothManager.isScanning ? 0 : 1)
                                .animation(
                                    bluetoothManager.isScanning ?
                                    Animation.easeOut(duration: 1.5)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.3) : .default,
                                    value: bluetoothManager.isScanning
                                )
                        }
                        
                        // Ícone central
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 36, weight: .ultraLight))
                            .foregroundColor(bluetoothManager.isScanning ? .green : .white.opacity(0.5))
                    }
                    .frame(height: 150)
                    
                    VStack(spacing: 12) {
                        Text("CONEXÃO BLUETOOTH")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(2.5)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(bluetoothManager.connectionStatus)
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Status conectado
                if bluetoothManager.connectedDevice != nil {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            
                            Text("CONECTADO")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.15))
                        )
                        
                        Text(bluetoothManager.connectedDevice?.name ?? "Sensor Caktus")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle()
                            .fill(.white.opacity(0.03))
                            .overlay(
                                Rectangle()
                                    .stroke(.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                // Lista de dispositivos com ScrollView
                VStack(spacing: 0) {
                    if bluetoothManager.isScanning || !bluetoothManager.discoveredDevices.isEmpty {
                        HStack {
                            Rectangle()
                                .fill(.green)
                                .frame(width: 3, height: 14)
                            Text("DISPOSITIVOS DISPONÍVEIS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    
                    if bluetoothManager.isScanning {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(.green)
                                .scaleEffect(0.9)
                            Text("ESCANEANDO...")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            Rectangle()
                                .fill(.white.opacity(0.03))
                        )
                        .padding(.horizontal, 20)
                    } else if bluetoothManager.discoveredDevices.isEmpty && bluetoothManager.connectedDevice == nil && !bluetoothManager.isScanning {
                        VStack(spacing: 16) {
                            Image(systemName: "sensor")
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.2))
                            
                            Text("Nenhum dispositivo encontrado")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("Toque em ESCANEAR para iniciar")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    if !bluetoothManager.discoveredDevices.isEmpty {
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(Array(bluetoothManager.discoveredDevices.enumerated()), id: \.element.identifier) { index, device in
                                    DeviceRowTech(
                                        device: device,
                                        index: index + 1
                                    ) {
                                        bluetoothManager.connect(to: device)
                                    }
                                }
                            }
                            .background(
                                Rectangle()
                                    .fill(.white.opacity(0.03))
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .frame(maxHeight: 300)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Botões
                VStack(spacing: 12) {
                    if bluetoothManager.connectedDevice == nil {
                        Button(action: {
                            if bluetoothManager.isScanning {
                                bluetoothManager.stopScanning()
                            } else {
                                bluetoothManager.startScanning()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: bluetoothManager.isScanning ? "stop.fill" : "magnifyingglass")
                                    .font(.system(size: 13, weight: .bold))
                                Text(bluetoothManager.isScanning ? "PARAR" : "ESCANEAR")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                Rectangle()
                                    .fill(.green)
                            )
                        }
                    } else {
                        Button(action: {
                            bluetoothManager.disconnect()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .bold))
                                Text("DESCONECTAR")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                Rectangle()
                                    .fill(.white.opacity(0.05))
                                    .overlay(
                                        Rectangle()
                                            .stroke(.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button(action: {
                            isConnected = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                Text("CONTINUAR")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                Rectangle()
                                    .fill(.green)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .alert("INFORMAÇÃO DO SISTEMA", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Para testar:\n1. Ative o Bluetooth no iPhone\n2. O sistema listará dispositivos próximos\n3. Toque em qualquer um para conectar (modo demo)")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAlert = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
}

struct DeviceRowTech: View {
    let device: CBPeripheral
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Número
                Text(String(format: "%02d", index))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 50)
                
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                
                // Ícone
                Image(systemName: "sensor")
                    .font(.system(size: 16, weight: .ultraLight))
                    .foregroundColor(.green)
                    .frame(width: 60)
                
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text((device.name ?? "SENSOR CAKTUS").uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white)
                    
                    Text(device.identifier.uuidString.prefix(18))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                // Signal indicator
                HStack(spacing: 2) {
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(.green)
                            .frame(width: 2, height: CGFloat(4 + i * 3))
                    }
                }
                .padding(.trailing, 20)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.trailing, 20)
            }
            .frame(height: 60)
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
