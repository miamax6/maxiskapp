# MaxiskApp

Lanceur de nos applis, perso (GitHub Pages) et Android (Home Assistant, MusicCast, Tricount…).

En ligne : https://miamax6.github.io/maxiskapp/

## Principe
- Chaque tuile a une cible **Android** (appli installée, lien web, ou masquée) et une cible **PC** (lien ou masquée).
- Favoris rangés à la main (crayon → étoile → glisser). Le reste est trié par usage.
- Rangement et favoris propres à chaque appareil.

## Jeton GitHub commun
Toutes les applis sont sur `miamax6.github.io` : même origine, donc même stockage local.
MaxiskApp écrit le jeton dans la config de Budget (`cc.cfg`) et de Jungle (`jg.cfg`).
Les applis n'ont pas été modifiées : elles restent utilisables seules.
Les phrases secrètes restent propres à chaque appli.

## Autre téléphone
Réglages → « Afficher le QR code ». Le QR est chiffré (AES-GCM) ; le code s'affiche à côté.

## Fichiers
`index.html` (tout, pictos Lucide intégrés — licence ISC), `qrcode.js` (qrcode-generator, MIT), `sw.js`, `manifest.webmanifest`, icônes.
