# Funathon 2024 - Sujet 1 :star:

Visualiser le trafic et/ou les émissions de C02 liées à une mesure de restriction de liaison aérienne relativement à des isochrones en trajet ferroviaire.

## Grandes parties

1. A partir des liaisons aériennes supprimées par la mesure 2h30, calculer le trafic théorique et les émissions impactées théoriques (si toutes les liaisons avaient été supprimées). Visualiser les différentes liaisons supprimées sur une carte de la France. Les traits seront d'une couleur différente selon le trafic et/ou les émissions de CO2 impacté.

2. Faire la même chose selon une mesure hypothétique des 4h30 :
   - Récupérer les liaisons impactées via une API qui calcule les isochrones train (gare à gare)
   - Visualiser les données comme précédent

3. Etendre aux liaisons Européennes

4. Rendre le code modulable selon le temps pris pour l'isochrone (ex. pouvoir choisir les isochrones 3h, ou 5h etc)

## Remarques

Partie 4 vraiment utile ?

### API isochrones
Liens des différentes API isochrones :

https://docs.mapbox.com/playground/isochrone/
Pas de mode "train" disponible

https://apidocs.geoapify.com/playground/isoline/
Pas de mode "train" disponible et nombre de crédits gratuits limité (que 55 requêtes à 4h30)

https://playground.traveltime.com/isochrones
Temps de l'isochrone de 4h00 au maximum


