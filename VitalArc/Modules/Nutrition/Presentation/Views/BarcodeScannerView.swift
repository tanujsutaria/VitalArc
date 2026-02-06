//
//  BarcodeScannerView.swift
//  VitalArc
//
//  Barcode scanner for looking up foods by UPC/EAN
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Binding var scannedBarcode: String?
    @Environment(\.dismiss) var dismiss
    @State private var isPermissionDenied = false

    var body: some View {
        ZStack {
            if isPermissionDenied {
                VitalEmptyState(
                    icon: "camera.fill.badge.ellipsis",
                    title: "Camera Access Required",
                    message: "Please enable camera access in Settings to scan barcodes",
                    actionTitle: "Open Settings"
                ) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.vitalAdaptiveBackground)
            } else {
                CameraPreview(scannedCode: $scannedBarcode, isPermissionDenied: $isPermissionDenied)
                    .ignoresSafeArea()

                VStack {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("Scan Product Barcode")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("Position barcode within the frame")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    .padding(Spacing.md)
                    .background(.ultraThinMaterial)
                    .cornerRadius(Spacing.radiusMedium)
                    .padding(.top, Spacing.xxxl)

                    Spacer()

                    // Scanning frame
                    ScannerFrame()
                        .frame(width: 280, height: 180)

                    Spacer()

                    // Cancel button
                    VitalButton(
                        title: "Cancel",
                        style: .secondary,
                        size: .large,
                        fullWidth: true
                    ) {
                        dismiss()
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .onChange(of: scannedBarcode) { _, newValue in
            if newValue != nil {
                // Add haptic feedback
                HapticFeedback.success()

                // Dismiss after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Scanner Frame Overlay

private struct ScannerFrame: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Corner brackets
                Path { path in
                    let size: CGFloat = Spacing.xl
                    let lineWidth: CGFloat = Spacing.borderThick

                    // Top-left corner
                    path.move(to: CGPoint(x: 0, y: size))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size, y: 0))

                    // Top-right corner
                    path.move(to: CGPoint(x: geometry.size.width - size, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: size))

                    // Bottom-left corner
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - size))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: size, y: geometry.size.height))

                    // Bottom-right corner
                    path.move(to: CGPoint(x: geometry.size.width - size, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - size))
                }
                .stroke(Color.vitalAdaptiveTextPrimary, lineWidth: Spacing.borderThick)
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    @Binding var scannedCode: String?
    @Binding var isPermissionDenied: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        // Check camera permission
        checkCameraPermission { granted in
            if granted {
                context.coordinator.setupCamera(in: view)
            } else {
                DispatchQueue.main.async {
                    isPermissionDenied = true
                }
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String?
        private var captureSession: AVCaptureSession?
        private var previewLayer: AVCaptureVideoPreviewLayer?

        init(scannedCode: Binding<String?>) {
            _scannedCode = scannedCode
        }

        func setupCamera(in view: UIView) {
            let session = AVCaptureSession()

            // Silent failure acceptable - camera initialization failure means hardware is unavailable
            // The guard handles this gracefully by returning early
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
                  session.canAddInput(videoInput) else {
                return
            }

            session.addInput(videoInput)

            let metadataOutput = AVCaptureMetadataOutput()

            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39, .code93]
            } else {
                return
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            self.captureSession = session
            self.previewLayer = previewLayer

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                scannedCode = stringValue

                // Stop scanning after successful scan
                captureSession?.stopRunning()
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var barcode: String?

        var body: some View {
            BarcodeScannerView(scannedBarcode: $barcode)
        }
    }

    return PreviewWrapper()
}
