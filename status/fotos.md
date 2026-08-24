# Foto's

## Status
Je kunt foto's toevoegen bij een voertuig, bij een logregel en bij een service (camera of bibliotheek). Bestanden staan in de app-map; in de garage zie je de eerste voertuigfoto als icoon.

## Openstaand
- Maximaal 8 foto's per plek.
- Foto's gaan niet mee in een cloud-backup, alleen lokaal op het toestel.

## Beslissingen
- Geen base64 in AsyncStorage — te groot en traag. Alleen het pad wordt opgeslagen.
- Bij een service hangen dezelfde foto's aan elk afgevinkt item, zodat ze in de geschiedenis bij die categorie blijven staan.
