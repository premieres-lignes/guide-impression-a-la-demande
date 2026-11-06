# L'impression à la demande en France — guide pratique

Ce guide en LaTeX s'adresse aux **petits éditeurs** et aux **auteurs indépendants**.
Il présente le fonctionnement, le cadre légal, les prix et les acteurs de
l'impression à la demande (IAD) en France : Amazon KDP, BoD, IngramSpark, Bookelis…

La charte graphique est celle de **Premières Lignes** : orange vif, noir,
titres en slab serif très gras et mots de liaison en italique. Une bannière
d'abonnement à la newsletter (avec QR code) figure sur la couverture et en fin
de document.

---

## 1. Prérequis

Il faut une distribution TeX récente avec **XeLaTeX** (ou LuaLaTeX) et **latexmk**.

| Système | Installation |
|---|---|
| Fedora | `sudo dnf install latexmk texlive-scheme-medium texlive-collection-latexextra texlive-collection-langfrench texlive-tex-gyre texlive-qrcode` (ou plus simplement `texlive-scheme-full`) |
| Debian / Ubuntu | `sudo apt install latexmk texlive-xetex texlive-latex-extra texlive-lang-french texlive-fonts-extra` |
| macOS | [MacTeX](https://tug.org/mactex/) |
| Windows | [MiKTeX](https://miktex.org/) ou [TeX Live](https://tug.org/texlive/) |

Paquets LaTeX utilisés : `fontspec`, `babel` (french), `xcolor`, `tikz`,
`tcolorbox`, `eso-pic`, `titlesec`, `fancyhdr`, `enumitem`, `booktabs`,
`tabularx`, `xfp`, `siunitx`, `microtype`, `csquotes`, `hyperref`, `qrcode`.

**Sans installer TeX Live — avec [Tectonic](https://tectonic-typesetting.github.io)** (un seul binaire, il télécharge les paquets nécessaires au premier lancement) :

```bash
mkdir -p .tools && curl -fsSL -o /tmp/tectonic.tar.gz \
  https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.17.0/tectonic-0.17.0-x86_64-unknown-linux-musl.tar.gz
tar xzf /tmp/tectonic.tar.gz -C .tools
make fonts && make tectonic
```

**Ou avec Podman / Docker** :

```bash
podman run --rm -v "$PWD":/work:Z -w /work docker.io/texlive/texlive:latest \
  latexmk -xelatex -outdir=build main.tex
```

## 2. Compiler

```bash
make fonts   # une seule fois : télécharge les polices de la charte dans fonts/
make         # produit guide-impression-a-la-demande.pdf
```

Autres commandes :

```bash
make watch              # recompile automatiquement à chaque sauvegarde
make ENGINE=lualatex    # compiler avec LuaLaTeX au lieu de XeLaTeX
make clean              # supprime les fichiers temporaires (build/)
make distclean          # supprime aussi le PDF
```

Sans `make` : `latexmk -xelatex -outdir=build main.tex`. Le PDF est alors dans `build/main.pdf`.

> Lancez toujours la compilation **depuis la racine du projet** : les chemins
> `fonts/`, `style/`, `chapitres/` et `donnees/` sont relatifs à ce dossier.

### Polices

| Rôle | Police de la charte | Repli automatique si absente |
|---|---|---|
| Titres | Alfa Slab One | TeX Gyre Bonum Bold |
| Mots en italique (« à la », « en ») | Zilla Slab Bold Italic | TeX Gyre Bonum Bold Italic |
| Texte courant | Lato | TeX Gyre Heros |

Ces polices sont sous licence SIL Open Font License et proviennent de Google Fonts.
Si `make fonts` n'a pas été lancé, le document compile quand même avec les
polices de repli et affiche un avertissement.

## 3. Structure du projet

```
main.tex                    ← point d'entrée + RÉGLAGES RAPIDES (textes couverture, newsletter)
style/premiereslignes.sty   ← toute la charte : couleurs, polices, titres, encadrés, bannière
donnees/parametres.tex      ← chiffres des exemples (prix, pages, taux) → calculs automatiques
donnees/interviews.tex      ← vidéos YouTube mises en avant
images/youtube/             ← miniatures des vidéos
chapitres/
  00-avant-propos.tex       ← mode d'emploi + sommaire
  01-principe.tex           ← qu'est-ce que l'IAD, comparaison offset/numérique
  02-fonctionnement.tex     ← chaîne technique, formats, fichiers, distribution
  03-cadre-legal.tex        ← loi Lang, frais de port, TVA, ISBN, dépôt légal, GPSR, statuts
  04-prix.tex               ← structure du prix, exemples KDP / librairie / offset
  05-acteurs.tex            ← fiches KDP, BoD, IngramSpark, Bookelis… + comparatif
  06-mise-en-place.tex      ← pas-à-pas et checklists
  07-ressources.tex         ← glossaire et liens
  08-interviews.tex         ← sélection d'interviews YouTube + page « Restons en contact »
fonts/                      ← polices (remplies par `make fonts`)
site/                       ← sources du site de téléchargement
docs/                       ← site généré (GitHub Pages)
Makefile
```

## 4. Personnaliser

### Textes de couverture et newsletter
Tout se trouve en haut de `main.tex` (bloc « RÉGLAGES RAPIDES ») :
`\plMarque`, `\plSurtitre`, `\plSousTitre`, `\plNewsletterURL`,
`\plNewsletterTitre`, `\plNewsletterTexte`, `\plNewsletterBouton`…
Le QR code est régénéré automatiquement à partir de `\plNewsletterURL`.

Pour ajouter la bannière ailleurs dans le document, il suffit d'écrire `\bannierenewsletter`.

### Couleurs
Dans `style/premiereslignes.sty`, section 1 :

```latex
\definecolor{plOrange}{HTML}{FF7A00}
\definecolor{plOrangeClair}{HTML}{FFA033}  % centre du dégradé de couverture
\definecolor{plOrangeFonce}{HTML}{E35A00}
```

### Ajouter, retirer ou réordonner un chapitre
Dans `main.tex`, commentez (`%`) ou déplacez les lignes `\input{chapitres/...}`.
Pour un nouveau chapitre, créez `chapitres/08-xxx.tex` qui commence par
`\section{Titre}`, puis ajoutez `\input{chapitres/08-xxx} \clearpage`.

### Encadrés disponibles

```latex
\begin{astuce}[Titre facultatif] ... \end{astuce}        % fond crème, filet orange
\begin{attention}[Titre facultatif] ... \end{attention}  % point de vigilance
\begin{fiche}{Nom de l'acteur}{site.fr} ... \end{fiche}  % fiche acteur (site vide = pas de lien)
\chiffrecle{3 €}{Texte explicatif}                       % chiffre clé sur fond orange
\begin{checklist} \item ... \end{checklist}              % liste à cocher
\source{Texte}                                           % petite note grise
```

Dans les tableaux, `\entete` en début de ligne colore la ligne d'en-tête en orange.

### Chaîne YouTube et interviews
- Liens et textes de la chaîne : bloc « RÉGLAGES RAPIDES » de `main.tex` (`\plYoutubeURL`, `\plYoutubeTexte`…).
- Vidéos mises en avant : `donnees/interviews.tex`, une ligne `\interview{ID}{Titre}{Invité}{Accroche}` par vidéo.
  L'ID est la partie qui suit `watch?v=` dans l'URL. La miniature doit être placée dans `images/youtube/<ID>.jpg` :
  ```bash
  curl -o images/youtube/ID.jpg https://i.ytimg.com/vi/ID/maxresdefault.jpg
  ```
- Encadré « À voir » dans un chapitre : `\avoir{ID}{Texte}`. Bannière de la chaîne : `\banniereyoutube`.
- Sur le site, la même liste se trouve dans la section `#interviews` de `site/index.html`.

### Exemples chiffrés
Modifiez `donnees/parametres.tex` (prix TTC, nombre de pages, barème KDP,
remise libraire, coût d'un tirage offset…). Les tableaux du chapitre 4 sont
recalculés à la compilation grâce à `xfp`. Les macros `\eur{expr}`,
`\pct{expr}` et `\entier{expr}` formatent les résultats à la française
(`4,35 €`).

## 5. Retoucher le PDF avec pypdf (facultatif)

Le PDF généré peut être modifié sans recompiler, par exemple pour ajouter
une page conçue dans un autre outil :

```python
from pypdf import PdfReader, PdfWriter

guide = PdfReader("guide-impression-a-la-demande.pdf")
encart = PdfReader("encart.pdf")
w = PdfWriter()
w.append(guide, pages=(0, 1))   # couverture
w.append(encart)                # votre page
w.append(guide, pages=(1, len(guide.pages)))
w.write("guide-final.pdf")
```

Pour modifier le contenu lui-même, il vaut mieux passer par les sources LaTeX.

## 6. Site de téléchargement (GitHub Pages)

Une page statique aux couleurs de la charte permet de télécharger le PDF directement
et invite à s'abonner à la newsletter.

```
site/                ← SOURCES : c'est ici qu'on modifie
  index.html         ← la page (contient le marqueur {{SITE_URL}})
  style.css          ← couleurs et typographie (variables CSS en tête)
  og-image.html      ← modèle de l'image d'aperçu réseaux sociaux (1200×630)
docs/                ← GÉNÉRÉ par « make site », publié par GitHub Pages (ne pas éditer)
  index.html, style.css, fonts/, guide-impression-a-la-demande.pdf,
  couverture.png, og-image.png, CNAME, .nojekyll
```

### Générer le site

```bash
make tectonic                                              # (ou make) compile le PDF
make site SITE_URL=https://guide.premiereslignes.studio/   # génère docs/
```

`make site` fait les opérations suivantes :
- il remplace `{{SITE_URL}}` par l'adresse publique dans toutes les balises
  **Open Graph** / **Twitter** (`og:url`, `og:image` en URL absolue, dimensions,
  texte alternatif…) et dans le lien canonique ;
- il crée l'image d'aperçu `og-image.png` (1200×630) avec Chrome ou Chromium en mode headless ;
- il produit `couverture.png` à partir du PDF (nécessite `pdftoppm`, paquet poppler-utils) ;
- il écrit `docs/CNAME` pour un domaine personnalisé (rien n'est écrit pour une adresse en `*.github.io`).

La valeur par défaut de `SITE_URL` se change en haut du bloc « Site » du `Makefile`.
**N'oubliez pas le `/` final.**

### Aperçu en local

```bash
make serve            # puis ouvrez http://127.0.0.1:8000
make serve PORT=8080  # sur un autre port
```

En local, les balises Open Graph pointent vers l'adresse publique : elles ne fonctionneront qu'une fois le site en ligne.

### Mettre en ligne

1. Poussez le projet sur GitHub, en incluant `docs/`.
2. Sur GitHub, ouvrez *Settings → Pages* : choisissez *Deploy from a branch*, la branche `main`
   et le dossier `/docs`.
3. **Domaine personnalisé** : chez votre registrar, créez un enregistrement DNS
   `CNAME guide → <compte>.github.io`, puis cochez *Enforce HTTPS* dans *Settings → Pages*.

### Vérifier l'aperçu sur les réseaux

Une fois le site en ligne, testez l'URL avec les outils suivants :
- Facebook : https://developers.facebook.com/tools/debug/ (le bouton « Scrape again » vide le cache)
- LinkedIn : https://www.linkedin.com/post-inspector/
- Toutes plateformes : https://www.opengraph.xyz/

Les réseaux gardent l'aperçu en cache. Après avoir changé l'image, renommez-la
(par exemple `og-image-v2.png`, dans `site/index.html` et dans le `Makefile`) ou relancez le scraping.

## 7. Mise à jour du contenu

Les tarifs et conditions des plateformes (KDP, BoD, IngramSpark…) changent
régulièrement. Les chiffres du guide sont des ordres de grandeur datés de
novembre 2026 : relisez en priorité les chapitres 3, 4 et 5 avant chaque
nouvelle diffusion.
