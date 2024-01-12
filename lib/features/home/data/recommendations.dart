import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:assets_audio_player/assets_audio_player.dart';
import '../model/recommendation_model.dart';



class RecommendationsData {
  static List<RecommendationModel> all = [];
  static AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  static Future<void> fetchDataFromApi() async {
    try {
      final response =
      await http.get(Uri.parse('http://192.168.2.11:8080/api/sounds'));
      print("Dữ liệu API: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Clear the existing recommendations
        all.clear();

        // Populate the list with new recommendations
        all.addAll(data.map<RecommendationModel>((json) {
          return RecommendationModel(
            title: json['name'],
            color: _getMaterialColorFromName(json['color']),
            duration: json['duration'],
            slogan: json['slogan'],
            author: json['author'],
            sound: "assets/sound/" + json['urlSound'],
          );
        }).toList());
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error fetching data from API: $e');
    }
  }

  static MaterialColor _getMaterialColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.blue; // Default color if the name is not recognized
    }
  }

/*  static Future<void> playSound(String soundUrl) async {
    // Stop any existing playback before starting a new one
    audioPlayer.stop();

    // Build the path to the asset
    String assetPath = 'assets/sound/$soundUrl';

    // Play audio from the asset
    audioPlayer.open(Audio(assetPath));
  }*/

  static RecommendationModel mindfulMoments = RecommendationModel(
    title: 'Mindful Moments',
    color: Colors.blue,
    duration: '10 to 20 min',
    slogan:
    "The goal is to become more aware of \n your thoughts and emotions how...",
    author: "Aggam Agrawal",
    sound: 'glass.mp3',
  );
}
