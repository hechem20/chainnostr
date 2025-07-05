# Dockerfile

FROM cirrusci/flutter:latest

# Créer le dossier de travail
WORKDIR /app

# Copier le projet dans le conteneur
COPY . .

# Installer les dépendances
RUN flutter pub get

# Builder l'application Android (APK)
RUN flutter build apk

# Le chemin de sortie sera : build/app/outputs/flutter-apk/app-release.apk
