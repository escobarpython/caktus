import SwiftUI

@main
struct CaktusApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isLoggedIn = false
    @State private var isBluetoothConnected = false
    
    var body: some Scene {
        WindowGroup {
            if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else if !isBluetoothConnected {
                BluetoothView(
                    bluetoothManager: bluetoothManager,
                    isConnected: $isBluetoothConnected
                )
            } else {
                PlantSelectionView(bluetoothManager: bluetoothManager)
            }
        }
    }
}
