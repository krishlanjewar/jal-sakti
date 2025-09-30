import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:jal_shakti_app/features/map/data/dwlr_station.dart';
import 'package:jal_shakti_app/features/map/data/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  
  List<DwlrStation> _allStations = [];
  List<DwlrStation> _filteredStations = [];
  Set<Marker> _markers = {};
  DwlrStation? _selectedStation;
  bool _isLoading = true;
  String? _errorMessage;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    _fetchStations();
    _searchController.addListener(_filterStations);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStations);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStations() async {
    List<DwlrStation> stations = [];
    try {
      stations = await _mapService.getDwlrStations();
      if (stations.isEmpty) {
        print("Primary data source is empty or failed to load. Using fallback stations.");
        stations = _getFallbackStations();
      }
    } catch (e) {
      print("A critical error occurred during data fetching: $e");
      setState(() {
         _errorMessage = "Could not load data. Showing default stations.";
      });
      stations = _getFallbackStations();
    }

    setState(() {
      _allStations = stations;
      _filteredStations = stations;
      _updateMarkers();
      _isLoading = false;
    });
  }
  
  // --- UPDATED: Expanded list of fallback stations ---
  List<DwlrStation> _getFallbackStations() {
    return [
      // Original Maharashtra Stations
      DwlrStation(id: 'FALLBACK_PUNE', name: 'Pune DWLR (Default)', state: 'Maharashtra', district: 'Pune', position: const LatLng(18.5204, 73.8567), waterLevel: 22.5, pH: 7.1, temperature: 28.3, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_MUMBAI', name: 'Mumbai DWLR (Default)', state: 'Maharashtra', district: 'Mumbai', position: const LatLng(19.0760, 72.8777), waterLevel: 12.1, pH: 6.8, temperature: 30.1, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_NAGPUR', name: 'Nagpur DWLR (Default)', state: 'Maharashtra', district: 'Nagpur', position: const LatLng(21.1458, 79.0882), waterLevel: 45.9, pH: 7.5, temperature: 32.5, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_NASHIK', name: 'Nashik DWLR (Default)', state: 'Maharashtra', district: 'Nashik', position: const LatLng(19.9975, 73.7898), waterLevel: 35.2, pH: 7.3, temperature: 27.9, waterQualityNotes: 'Normal'),
      
      // Original 25 Additional Stations
      DwlrStation(id: 'FALLBACK_DELHI', name: 'Delhi DWLR', state: 'Delhi', district: 'New Delhi', position: const LatLng(28.6139, 77.2090), waterLevel: 8.9, pH: 7.8, temperature: 35.1, waterQualityNotes: 'Critically Low'),
      DwlrStation(id: 'FALLBACK_BANGALORE', name: 'Bangalore DWLR', state: 'Karnataka', district: 'Bengaluru Urban', position: const LatLng(12.9716, 77.5946), waterLevel: 55.2, pH: 7.0, temperature: 26.5, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_CHENNAI', name: 'Chennai DWLR', state: 'Tamil Nadu', district: 'Chennai', position: const LatLng(13.0827, 80.2707), waterLevel: 14.5, pH: 6.7, temperature: 31.0, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_HYDERABAD', name: 'Hyderabad DWLR', state: 'Telangana', district: 'Hyderabad', position: const LatLng(17.3850, 78.4867), waterLevel: 18.0, pH: 7.3, temperature: 29.8, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_KOLKATA', name: 'Kolkata DWLR', state: 'West Bengal', district: 'Kolkata', position: const LatLng(22.5726, 88.3639), waterLevel: 51.0, pH: 7.2, temperature: 30.5, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_JAIPUR', name: 'Jaipur DWLR', state: 'Rajasthan', district: 'Jaipur', position: const LatLng(26.9124, 75.7873), waterLevel: 9.5, pH: 8.1, temperature: 36.2, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_AHMEDABAD', name: 'Ahmedabad DWLR', state: 'Gujarat', district: 'Ahmedabad', position: const LatLng(23.0225, 72.5714), waterLevel: 25.6, pH: 7.9, temperature: 34.0, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_LUCKNOW', name: 'Lucknow DWLR', state: 'Uttar Pradesh', district: 'Lucknow', position: const LatLng(26.8467, 80.9462), waterLevel: 33.1, pH: 7.4, temperature: 33.3, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_BHOPAL', name: 'Bhopal DWLR', state: 'Madhya Pradesh', district: 'Bhopal', position: const LatLng(23.2599, 77.4126), waterLevel: 28.9, pH: 7.6, temperature: 31.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_PATNA', name: 'Patna DWLR', state: 'Bihar', district: 'Patna', position: const LatLng(25.5941, 85.1376), waterLevel: 42.0, pH: 7.0, temperature: 32.8, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_GUWAHATI', name: 'Guwahati DWLR', state: 'Assam', district: 'Kamrup Metropolitan', position: const LatLng(26.1445, 91.7362), waterLevel: 60.5, pH: 6.9, temperature: 28.0, waterQualityNotes: 'Very High'),
      DwlrStation(id: 'FALLBACK_SHIMLA', name: 'Shimla DWLR', state: 'Himachal Pradesh', district: 'Shimla', position: const LatLng(31.1048, 77.1734), waterLevel: 38.0, pH: 7.2, temperature: 18.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_SRINAGAR', name: 'Srinagar DWLR', state: 'Jammu and Kashmir', district: 'Srinagar', position: const LatLng(34.0837, 74.7973), waterLevel: 41.5, pH: 7.3, temperature: 15.2, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_DEHRADUN', name: 'Dehradun DWLR', state: 'Uttarakhand', district: 'Dehradun', position: const LatLng(30.3165, 78.0322), waterLevel: 39.8, pH: 7.1, temperature: 24.9, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_RANCHI', name: 'Ranchi DWLR', state: 'Jharkhand', district: 'Ranchi', position: const LatLng(23.3441, 85.3096), waterLevel: 24.7, pH: 6.8, temperature: 29.1, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_RAIPUR', name: 'Raipur DWLR', state: 'Chhattisgarh', district: 'Raipur', position: const LatLng(21.2514, 81.6296), waterLevel: 20.3, pH: 7.5, temperature: 31.8, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_BHUBANESWAR', name: 'Bhubaneswar DWLR', state: 'Odisha', district: 'Khurda', position: const LatLng(20.2961, 85.8245), waterLevel: 48.2, pH: 7.0, temperature: 30.9, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_CHANDIGARH', name: 'Chandigarh DWLR', state: 'Chandigarh', district: 'Chandigarh', position: const LatLng(30.7333, 76.7794), waterLevel: 17.5, pH: 7.7, temperature: 34.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_PANAJI', name: 'Panaji DWLR', state: 'Goa', district: 'North Goa', position: const LatLng(15.4909, 73.8278), waterLevel: 33.8, pH: 7.2, temperature: 28.8, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_TRIVANDRUM', name: 'Trivandrum DWLR', state: 'Kerala', district: 'Thiruvananthapuram', position: const LatLng(8.5241, 76.9366), waterLevel: 44.1, pH: 6.9, temperature: 29.4, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_GANGTOK', name: 'Gangtok DWLR', state: 'Sikkim', district: 'East Sikkim', position: const LatLng(27.3389, 88.6065), waterLevel: 52.3, pH: 7.1, temperature: 17.1, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_IMPHAL', name: 'Imphal DWLR', state: 'Manipur', district: 'Imphal West', position: const LatLng(24.8170, 93.9368), waterLevel: 47.6, pH: 7.0, temperature: 25.3, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_AGARTALA', name: 'Agartala DWLR', state: 'Tripura', district: 'West Tripura', position: const LatLng(23.8315, 91.2868), waterLevel: 36.9, pH: 6.8, temperature: 29.7, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_PUDUCHERRY', name: 'Puducherry DWLR', state: 'Puducherry', district: 'Puducherry', position: const LatLng(11.9416, 79.8083), waterLevel: 11.8, pH: 7.4, temperature: 30.4, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_VIJAYAWADA', name: 'Vijayawada DWLR', state: 'Andhra Pradesh', district: 'Krishna', position: const LatLng(16.5062, 80.6480), waterLevel: 29.4, pH: 7.6, temperature: 32.1, waterQualityNotes: 'Normal'),

      // --- NEW 50 Additional Stations ---
      DwlrStation(id: 'FALLBACK_INDORE', name: 'Indore DWLR', state: 'Madhya Pradesh', district: 'Indore', position: const LatLng(22.7196, 75.8577), waterLevel: 19.8, pH: 7.5, temperature: 30.0, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_SURAT', name: 'Surat DWLR', state: 'Gujarat', district: 'Surat', position: const LatLng(21.1702, 72.8311), waterLevel: 22.1, pH: 8.0, temperature: 31.2, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_KANPUR', name: 'Kanpur DWLR', state: 'Uttar Pradesh', district: 'Kanpur Nagar', position: const LatLng(26.4499, 80.3319), waterLevel: 14.9, pH: 7.8, temperature: 34.1, waterQualityNotes: 'Slightly Low'),
      DwlrStation(id: 'FALLBACK_VISAKHAPATNAM', name: 'Visakhapatnam DWLR', state: 'Andhra Pradesh', district: 'Visakhapatnam', position: const LatLng(17.6868, 83.2185), waterLevel: 30.5, pH: 7.3, temperature: 30.0, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_THANE', name: 'Thane DWLR', state: 'Maharashtra', district: 'Thane', position: const LatLng(19.2183, 72.9781), waterLevel: 16.3, pH: 7.0, temperature: 29.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_AGRA', name: 'Agra DWLR', state: 'Uttar Pradesh', district: 'Agra', position: const LatLng(27.1767, 78.0081), waterLevel: 7.8, pH: 8.2, temperature: 35.8, waterQualityNotes: 'Very Low'),
      DwlrStation(id: 'FALLBACK_VADODARA', name: 'Vadodara DWLR', state: 'Gujarat', district: 'Vadodara', position: const LatLng(22.3072, 73.1812), waterLevel: 24.0, pH: 7.7, temperature: 33.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_LUDHIANA', name: 'Ludhiana DWLR', state: 'Punjab', district: 'Ludhiana', position: const LatLng(30.9010, 75.8573), waterLevel: 10.2, pH: 7.9, temperature: 34.8, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_KOCHI', name: 'Kochi DWLR', state: 'Kerala', district: 'Ernakulam', position: const LatLng(9.9312, 76.2673), waterLevel: 48.0, pH: 6.7, temperature: 29.0, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_COIMBATORE', name: 'Coimbatore DWLR', state: 'Tamil Nadu', district: 'Coimbatore', position: const LatLng(11.0168, 76.9558), waterLevel: 21.8, pH: 7.1, temperature: 28.2, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_VARANASI', name: 'Varanasi DWLR', state: 'Uttar Pradesh', district: 'Varanasi', position: const LatLng(25.3176, 82.9739), waterLevel: 43.1, pH: 7.5, temperature: 33.0, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_AMRITSAR', name: 'Amritsar DWLR', state: 'Punjab', district: 'Amritsar', position: const LatLng(31.6340, 74.8723), waterLevel: 11.5, pH: 8.0, temperature: 35.1, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_ALLAHABAD', name: 'Allahabad DWLR', state: 'Uttar Pradesh', district: 'Prayagraj', position: const LatLng(25.4358, 81.8463), waterLevel: 40.8, pH: 7.6, temperature: 33.7, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_JODHPUR', name: 'Jodhpur DWLR', state: 'Rajasthan', district: 'Jodhpur', position: const LatLng(26.2389, 73.0243), waterLevel: 6.5, pH: 8.3, temperature: 37.0, waterQualityNotes: 'Critically Low'),
      DwlrStation(id: 'FALLBACK_MADURAI', name: 'Madurai DWLR', state: 'Tamil Nadu', district: 'Madurai', position: const LatLng(9.9252, 78.1198), waterLevel: 19.2, pH: 7.2, temperature: 30.8, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_GURGAON', name: 'Gurgaon DWLR', state: 'Haryana', district: 'Gurugram', position: const LatLng(28.4595, 77.0266), waterLevel: 5.9, pH: 8.1, temperature: 35.5, waterQualityNotes: 'Critically Low'),
      DwlrStation(id: 'FALLBACK_CUTTACK', name: 'Cuttack DWLR', state: 'Odisha', district: 'Cuttack', position: const LatLng(20.4625, 85.8830), waterLevel: 46.7, pH: 7.1, temperature: 31.2, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_JAMSHEDPUR', name: 'Jamshedpur DWLR', state: 'Jharkhand', district: 'East Singhbhum', position: const LatLng(22.8046, 86.2029), waterLevel: 26.8, pH: 6.9, temperature: 30.4, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_UDAIPUR', name: 'Udaipur DWLR', state: 'Rajasthan', district: 'Udaipur', position: const LatLng(24.5854, 73.7125), waterLevel: 13.4, pH: 8.0, temperature: 34.6, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_KOZHIKODE', name: 'Kozhikode DWLR', state: 'Kerala', district: 'Kozhikode', position: const LatLng(11.2588, 75.7804), waterLevel: 49.3, pH: 6.8, temperature: 28.9, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_GWALIOR', name: 'Gwalior DWLR', state: 'Madhya Pradesh', district: 'Gwalior', position: const LatLng(26.2183, 78.1828), waterLevel: 16.7, pH: 7.7, temperature: 34.3, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_WARANGAL', name: 'Warangal DWLR', state: 'Telangana', district: 'Warangal', position: const LatLng(17.9689, 79.5941), waterLevel: 23.5, pH: 7.4, temperature: 31.1, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_MYSURU', name: 'Mysuru DWLR', state: 'Karnataka', district: 'Mysuru', position: const LatLng(12.2958, 76.6394), waterLevel: 31.2, pH: 7.2, temperature: 27.3, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_LEH', name: 'Leh DWLR', state: 'Ladakh', district: 'Leh', position: const LatLng(34.1526, 77.5771), waterLevel: 25.0, pH: 7.5, temperature: 5.4, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_PORTBLAIR', name: 'Port Blair DWLR', state: 'Andaman & Nicobar', district: 'South Andaman', position: const LatLng(11.6234, 92.7265), waterLevel: 55.0, pH: 7.1, temperature: 28.5, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_SILIGURI', name: 'Siliguri DWLR', state: 'West Bengal', district: 'Darjeeling', position: const LatLng(26.7271, 88.3953), waterLevel: 65.8, pH: 6.9, temperature: 27.1, waterQualityNotes: 'Very High'),
      DwlrStation(id: 'FALLBACK_JABALPUR', name: 'Jabalpur DWLR', state: 'Madhya Pradesh', district: 'Jabalpur', position: const LatLng(23.1815, 79.9864), waterLevel: 27.2, pH: 7.6, temperature: 31.0, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_ROURKELA', name: 'Rourkela DWLR', state: 'Odisha', district: 'Sundargarh', position: const LatLng(22.2492, 84.8827), waterLevel: 33.4, pH: 7.0, temperature: 30.7, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_GAYA', name: 'Gaya DWLR', state: 'Bihar', district: 'Gaya', position: const LatLng(24.7951, 85.0078), waterLevel: 15.1, pH: 7.3, temperature: 33.6, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_NELLORE', name: 'Nellore DWLR', state: 'Andhra Pradesh', district: 'Nellore', position: const LatLng(14.4426, 79.9865), waterLevel: 26.5, pH: 7.8, temperature: 31.4, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_AJMER', name: 'Ajmer DWLR', state: 'Rajasthan', district: 'Ajmer', position: const LatLng(26.4499, 74.6399), waterLevel: 10.8, pH: 8.2, temperature: 35.3, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_KOTA', name: 'Kota DWLR', state: 'Rajasthan', district: 'Kota', position: const LatLng(25.2138, 75.8648), waterLevel: 12.3, pH: 8.1, temperature: 36.0, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_TIRUCHIRAPPALLI', name: 'Tiruchirappalli DWLR', state: 'Tamil Nadu', district: 'Tiruchirappalli', position: const LatLng(10.7905, 78.7047), waterLevel: 22.9, pH: 7.2, temperature: 31.5, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_SALEM', name: 'Salem DWLR', state: 'Tamil Nadu', district: 'Salem', position: const LatLng(11.6643, 78.1460), waterLevel: 25.1, pH: 7.3, temperature: 29.9, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_HARIDWAR', name: 'Haridwar DWLR', state: 'Uttarakhand', district: 'Haridwar', position: const LatLng(29.9457, 78.1642), waterLevel: 47.2, pH: 7.4, temperature: 26.8, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_DURGAPUR', name: 'Durgapur DWLR', state: 'West Bengal', district: 'Paschim Bardhaman', position: const LatLng(23.5204, 87.3119), waterLevel: 31.7, pH: 7.1, temperature: 32.4, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_ASANSOL', name: 'Asansol DWLR', state: 'West Bengal', district: 'Paschim Bardhaman', position: const LatLng(23.6889, 86.9535), waterLevel: 29.8, pH: 7.0, temperature: 32.6, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_FARIDABAD', name: 'Faridabad DWLR', state: 'Haryana', district: 'Faridabad', position: const LatLng(28.4089, 77.3178), waterLevel: 6.2, pH: 8.0, temperature: 35.7, waterQualityNotes: 'Critically Low'),
      DwlrStation(id: 'FALLBACK_MEERUT', name: 'Meerut DWLR', state: 'Uttar Pradesh', district: 'Meerut', position: const LatLng(28.9845, 77.7064), waterLevel: 11.1, pH: 7.9, temperature: 34.9, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_JALANDHAR', name: 'Jalandhar DWLR', state: 'Punjab', district: 'Jalandhar', position: const LatLng(31.3260, 75.5762), waterLevel: 13.0, pH: 7.8, temperature: 35.0, waterQualityNotes: 'Low Level'),
      DwlrStation(id: 'FALLBACK_SHILLONG', name: 'Shillong DWLR', state: 'Meghalaya', district: 'East Khasi Hills', position: const LatLng(25.5788, 91.8933), waterLevel: 58.9, pH: 6.7, temperature: 20.1, waterQualityNotes: 'Very High'),
      DwlrStation(id: 'FALLBACK_AIZAWL', name: 'Aizawl DWLR', state: 'Mizoram', district: 'Aizawl', position: const LatLng(23.7367, 92.7146), waterLevel: 54.3, pH: 6.8, temperature: 24.3, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_KOHIMA', name: 'Kohima DWLR', state: 'Nagaland', district: 'Kohima', position: const LatLng(25.6751, 94.1026), waterLevel: 51.7, pH: 7.0, temperature: 22.8, waterQualityNotes: 'High Level'),
      DwlrStation(id: 'FALLBACK_ITANAGAR', name: 'Itanagar DWLR', state: 'Arunachal Pradesh', district: 'Papum Pare', position: const LatLng(27.0844, 93.6053), waterLevel: 62.1, pH: 6.9, temperature: 26.2, waterQualityNotes: 'Very High'),
      DwlrStation(id: 'FALLBACK_DIBRUGARH', name: 'Dibrugarh DWLR', state: 'Assam', district: 'Dibrugarh', position: const LatLng(27.4728, 94.9120), waterLevel: 63.4, pH: 6.8, temperature: 27.5, waterQualityNotes: 'Very High'),
      DwlrStation(id: 'FALLBACK_KAVARATTI', name: 'Kavaratti DWLR', state: 'Lakshadweep', district: 'Lakshadweep', position: const LatLng(10.5669, 72.6417), waterLevel: 35.0, pH: 7.9, temperature: 29.1, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_MARGAO', name: 'Margao DWLR', state: 'Goa', district: 'South Goa', position: const LatLng(15.2753, 73.9575), waterLevel: 31.5, pH: 7.1, temperature: 28.6, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_DAMAN', name: 'Daman DWLR', state: 'Daman and Diu', district: 'Daman', position: const LatLng(20.4283, 72.8397), waterLevel: 20.1, pH: 7.8, temperature: 30.2, waterQualityNotes: 'Normal'),
      DwlrStation(id: 'FALLBACK_TIRUPATI', name: 'Tirupati DWLR', state: 'Andhra Pradesh', district: 'Tirupati', position: const LatLng(13.6288, 79.4192), waterLevel: 28.3, pH: 7.5, temperature: 30.6, waterQualityNotes: 'Normal'),
    ];
  }


  void _filterStations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStations = _allStations.where((station) {
        return station.fullLocation.toLowerCase().contains(query);
      }).toList();
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final markers = _filteredStations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: station.position,
        icon: _getMarkerIcon(station.status),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: 'Water Level: ${station.waterLevel.toStringAsFixed(1)}m',
        ),
        onTap: () => _onMarkerTapped(station),
      );
    }).toSet();
    setState(() => _markers = markers);
  }

  void _onMarkerTapped(DwlrStation station) {
    setState(() => _selectedStation = station);
    _goToStation(station);
  }

  BitmapDescriptor _getMarkerIcon(WaterLevelStatus status) {
    switch (status) {
      case WaterLevelStatus.low: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case WaterLevelStatus.normal: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case WaterLevelStatus.high: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<void> _goToStation(DwlrStation station) async {
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: station.position, zoom: 14.0),
    ));
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.showMarkerInfoWindow(MarkerId(station.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) => _mapController.complete(controller),
            markers: _markers,
            onTap: (_) => setState(() => _selectedStation = null),
          ),
          
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          
          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          
          if (!_isLoading) ...[
            _buildLegend(),
            _buildDraggableSheet(),
          ]
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black26)],
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, district, or state...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Expanded(
                child: _filteredStations.isEmpty
                    ? const Center(child: Text('No stations found.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredStations.length,
                        itemBuilder: (context, index) {
                          final station = _filteredStations[index];
                          return _buildStationListItem(station, _selectedStation?.id == station.id);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationListItem(DwlrStation station, bool isSelected) {
    return ListTile(
      tileColor: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
      leading: _getIconForStatus(station.status),
      title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${station.district}, ${station.state}'),
      trailing: Text(
        '${station.waterLevel.toStringAsFixed(1)}m',
        style: TextStyle(
          color: _getColorForStatus(station.status),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: () => _onMarkerTapped(station),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.35 + 10,
      right: 10,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Water Level', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _buildLegendItem(Colors.green, 'High (>40m)'),
              _buildLegendItem(Colors.blue, 'Normal (15-40m)'),
              _buildLegendItem(Colors.red, 'Low (<15m)'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Color _getColorForStatus(WaterLevelStatus status) {
    switch (status) {
      case WaterLevelStatus.low: return Colors.red;
      case WaterLevelStatus.normal: return AppTheme.primaryBlue;
      case WaterLevelStatus.high: return Colors.green;
    }
  }

  Icon _getIconForStatus(WaterLevelStatus status) {
    return Icon(_getIconDataForStatus(status), color: _getColorForStatus(status));
  }
  
  IconData _getIconDataForStatus(WaterLevelStatus status) {
     switch (status) {
      case WaterLevelStatus.low: return Icons.arrow_downward;
      case WaterLevelStatus.normal: return Icons.horizontal_rule;
      case WaterLevelStatus.high: return Icons.arrow_upward;
    }
  }
}

