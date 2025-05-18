//
//  MapView.swift
//  GOPeat
//
//  Created by jonathan calvin sutrisna on 07/04/25.
//

import SwiftUI
import MapKit
import CoreLocation

// Global function for location color
func locationColor(for name: String) -> Color {
    switch name {
    case "GOP 1 Canteen": return .red
    case "GOP 6 Canteen": return .blue
    case "Green Eatery": return .green
    case "The Breeze Food Court": return .orange
    default: return .purple
    }
}

// Location authorization states
enum LocationAuthState {
    case notDetermined
    case denied
    case restricted
    case authorized
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authState: LocationAuthState = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authState = .authorized
            locationManager.startUpdatingLocation()
        case .denied:
            authState = .denied
        case .restricted:
            authState = .restricted
        case .notDetermined:
            authState = .notDetermined
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

struct MapView: View {
    @State private var camera: MapCameraPosition = .automatic
    @State private var selectedCanteen: Canteen?
    @State private var showDetail = false
    @State private var showSearchModal = false
    @State private var mapOffset: CGFloat = 0
    @StateObject private var locationManager = LocationManager()
    @StateObject private var tenantSearchViewModel: TenantSearchViewModel
    @State private var showTutorial = false

    let tenants: [Tenant]
    let canteens: [Canteen]

    init(tenants: [Tenant], canteens: [Canteen]) {
        self.tenants = tenants
        self.canteens = canteens
        self._tenantSearchViewModel = StateObject(wrappedValue: TenantSearchViewModel(tenants: tenants))
    }

    private func zoomToLocation(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            mapOffset = -UIScreen.main.bounds.height * 0.25
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
            camera = .region(region)
        }
    }

    private func handleCanteenSelection(_ canteen: Canteen) {
        selectedCanteen = canteen
        let coordinate = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
        zoomToLocation(coordinate)
        showDetail = true
        showSearchModal = false
        tenantSearchViewModel.onClose()
    }

    private func handleTenantSelection(_ tenant: Tenant) {
        guard let canteen = tenant.canteen else { return }
        let coordinate = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
        zoomToLocation(coordinate)
        tenantSearchViewModel.onClose()
        showSearchModal = false
        // TO DO: Navigate to Tenant Page
    }

    private func annotationContent(for canteen: Canteen) -> some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 30, height: 30)

            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(locationColor(for: canteen.name))
                .scaleEffect(selectedCanteen?.id == canteen.id ? 1.3 : 1.0)
        }
        .shadow(radius: 5)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                handleCanteenSelection(canteen)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Map View with Offset
            Map(position: $camera) {
                UserAnnotation()
                ForEach(canteens) { canteen in
                    Annotation(canteen.name, coordinate: CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)){
                        annotationContent(for: canteen)
                    }
                }
            }
            .padding(.top, mapOffset)
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.clear)

            // Location Status Indicator
            if locationManager.authState != .authorized {
                LocationStatusBanner(authState: locationManager.authState) {
                    if locationManager.authState == .notDetermined {
                        locationManager.requestLocationPermission()
                    } else {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            // Location Button moved to top right
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if let currentLocation = locationManager.location?.coordinate {
                            withAnimation {
                                camera = .region(MKCoordinateRegion(
                                    center: currentLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                                ))
                                mapOffset = 0
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing)
                }
                Spacer()
            }
            .padding(.top)

            // Tutorial Overlay
            if showTutorial {
                MapTutorialOverlay(isPresented: $showTutorial) {
                    withAnimation {
                        showTutorial = false
                        showSearchModal = true // Show search modal after tutorial
                    }
                }
            }
        }
        .sheet(isPresented: $showDetail, onDismiss: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedCanteen = nil
                showSearchModal = true
                mapOffset = 0
            }
        }) {
            if let canteen = selectedCanteen {
                CanteenDetail(canteen: canteen, dismissAction: {
                    showDetail = false
                })
                .presentationDetents([.fraction(0.95)])
            }
        }
        .sheet(isPresented: Binding(
            get: { showSearchModal && !showTutorial },
            set: { showSearchModal = $0 }
        ), onDismiss: {}) {
            ModalSearch(
                tenantSearchViewModel: tenantSearchViewModel
            )
        }
        .onAppear {
            // Show tutorial immediately when view appears
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation {
                    showTutorial = true
                }
            }
        }
    }
}

// Location Status Banner View
struct LocationStatusBanner: View {
    let authState: LocationAuthState
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: statusIcon)
                .font(.system(size: 12))
                .foregroundColor(statusColor)

            Text(statusMessage)
                .font(.footnote)
                .foregroundColor(.black.opacity(0.7))

            Button(action: action) {
                Text(buttonText)
                    .font(.footnote.bold())
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.top, 50)
        .frame(maxWidth: .infinity)
    }

    private var statusIcon: String {
        switch authState {
        case .notDetermined:
            return "location.circle"
        case .denied, .restricted:
            return "location.slash.circle"
        case .authorized:
            return "location.circle.fill"
        }
    }

    private var statusColor: Color {
        switch authState {
        case .notDetermined:
            return .orange
        case .denied, .restricted:
            return .red
        case .authorized:
            return .green
        }
    }

    private var statusMessage: String {
        switch authState {
        case .notDetermined:
            return "Enable location to find nearby canteens"
        case .denied:
            return "Location access needed"
        case .restricted:
            return "Location access unavailable"
        case .authorized:
            return ""
        }
    }

    private var buttonText: String {
        switch authState {
        case .notDetermined:
            return "Enable"
        case .denied, .restricted:
            return "Settings"
        case .authorized:
            return ""
        }
    }
}
