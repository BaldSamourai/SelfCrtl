#!/bin/bash

# Script to clean, get dependencies, and run a Flutter app

echo "Cleaning the project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Running the app..."
flutter run
