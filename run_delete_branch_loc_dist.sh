#!/bin/bash

# Vérifie si un argument a été passé
if [ -z "$1" ]; then
  echo "Erreur : Veuillez fournir le nom de la branche en paramètre."
  exit 1
fi

BRANCHE=$1

echo "Supprimer la branche localement"
git branch -d "$BRANCHE"

echo "Supprimer la branche à distance"
git push origin --delete "$BRANCHE"
