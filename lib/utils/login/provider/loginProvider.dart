import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:store/utils/network/service.dart';

class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> checkLogin() async {
    print("Checking login");
    String? phone = await storage.read(key: "phone");
    String? fcm = await storage.read(key: "fcm");

    try {
      final Map<String, dynamic> requestData = {"phone": phone, "fcm": fcm};

      final networkService = NetworkService();
      var response = await networkService.postWithAuth(
          '/manager-login', // Adjusted endpoint
          additionalData: requestData);
      // Send the POST request

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Assuming the API returns a JSON object with a field that indicates if the delivery exists
        final Manager manager = Manager.fromJson(data); // Adjusted to Delivery
        print("Manager: ${manager.id} ${manager.phone}");
        await storage.write(
            key: 'managerId', value: manager.id.toString()); // Adjusted key
        await storage.write(key: 'phone', value: manager.phone);
        await storage.write(key: 'name', value: manager.name);
        await storage.write(
            key: 'authToken',
            value: manager.token); // Assuming similar fields for delivery

        if (data['phone'].length == 10) {
          // Assuming the 'exists' logic remains the same
          return true;
        }
        return false;
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  Future<String> checkManagerExist(String phoneNumber, String fcm) async {
    // Adjusted method name
    try {
      final Map<String, dynamic> requestData = {
        "phone": phoneNumber,
        "fcm": fcm
      };

      final networkService = NetworkService();
      var response = await networkService.postWithAuth(
          '/manager-partner-login', // Adjusted endpoint
          additionalData: requestData);
      // Send the POST request

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Assuming the API returns a JSON object with a field that indicates if the delivery exists
        final Manager manager = Manager.fromJson(data); // Adjusted to Delivery
        print("Manager: ${manager.id} ${manager.phone}");
        await storage.write(
            key: 'managerId', value: manager.id.toString()); // Adjusted key
        await storage.write(key: 'phone', value: manager.phone);
        await storage.write(key: 'name', value: manager.name);
        await storage.write(
            key: 'authToken',
            value: manager.token); // Assuming similar fields for delivery

        return data[
            'phone']; // Replace 'exists' with the actual field name if different
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
        print(response.body);
        return 'error';
      }
    } catch (e) {
      print('Error occurred: $e');
      return 'error';
    }
  }
}

class Manager {
  // Adjusted class name
  final int id;
  final String name;
  final String phone;
  final String createdAt;
  final String token;

  Manager({
    // Constructor name adjusted
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.token,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    // Factory constructor name adjusted
    return Manager(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'],
      token: json['token'],
    );
  }
}
