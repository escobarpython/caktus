import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo - Cacto
                VStack(spacing: 30) {
                    ZStack {
                        // Hexágono de fundo
                        Image(systemName: "hexagon")
                            .font(.system(size: 100))
                            .foregroundColor(.green.opacity(0.15))
                        
                        // Cacto
                        Image(systemName: "camera.macro")
                            .font(.system(size: 50, weight: .ultraLight))
                            .foregroundColor(.green)
                    }
                    
                    // Nome do app
                    VStack(spacing: 8) {
                        Text("CAKTUS")
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .tracking(6)
                            .foregroundColor(.white)
                        
                        Text("2023 - 2024 - 2025")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(3)
                            .foregroundColor(.green.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Formulário
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Rectangle()
                            .fill(.green)
                            .frame(width: 3, height: 14)
                        Text("AUTENTICAÇÃO")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // Email
                    VStack(spacing: 8) {
                        HStack {
                            Text("EMAIL")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 40)
                            
                            TextField("", text: $email, prompt: Text("seu@email.com").foregroundColor(.white.opacity(0.3)))
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(.white)
                        }
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
                    
                    // Senha
                    VStack(spacing: 8) {
                        HStack {
                            Text("SENHA")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 40)
                            
                            SecureField("", text: $password, prompt: Text("••••••••").foregroundColor(.white.opacity(0.3)))
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(.white)
                        }
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
                    
                    // Botão Login
                    Button(action: login) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.black)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                Text("ENTRAR")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Rectangle()
                                .fill(.green)
                        )
                    }
                    .disabled(isLoading)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("DEMO MODE 2025")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(.green.opacity(0.7))
                    }
                    
                    Text("login: pedro // 1")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    func login() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isLoggedIn = true
            }
        }
    }
}
