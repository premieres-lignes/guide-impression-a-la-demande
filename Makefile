# Guide « L'impression à la demande en France »
# Usage : make            -> compile le PDF
#         make fonts      -> télécharge les polices de la charte (une fois)
#         make watch      -> recompile à chaque modification
#         make clean      -> supprime les fichiers temporaires

MAIN    := main
OUT     := build
PDF     := guide-impression-a-la-demande.pdf
ENGINE  ?= xelatex   # ou : make ENGINE=lualatex

GF      := https://github.com/google/fonts/raw/main/ofl
FONTS   := fonts/AlfaSlabOne-Regular.ttf fonts/ZillaSlab-BoldItalic.ttf \
           fonts/Lato-Regular.ttf fonts/Lato-Bold.ttf \
           fonts/Lato-Italic.ttf fonts/Lato-BoldItalic.ttf

.PHONY: all pdf tectonic site serve fonts watch clean distclean

all: pdf

pdf:
	latexmk -$(strip $(ENGINE)) -outdir=$(OUT) -interaction=nonstopmode -halt-on-error -file-line-error $(MAIN).tex
	cp $(OUT)/$(MAIN).pdf $(PDF)
	@echo "==> $(PDF) généré"

# Alternative sans TeX Live : Tectonic (binaire autonome, paquets téléchargés à la volée)
TECTONIC ?= $(shell command -v tectonic || echo .tools/tectonic)
tectonic:
	mkdir -p $(OUT)
	$(TECTONIC) -X compile $(MAIN).tex --outdir $(OUT)
	cp $(OUT)/$(MAIN).pdf $(PDF)
	@echo "==> $(PDF) généré"

# ---------------------------------------------------------------------
#  Site GitHub Pages : sources dans site/, résultat dans docs/
#  SITE_URL = adresse publique du site, avec le « / » final.
#  Elle sert aux balises Open Graph (aperçu sur les réseaux sociaux) et au
#  fichier CNAME (domaine personnalisé). Exemple :
#    make site SITE_URL=https://guide.premiereslignes.studio/
# ---------------------------------------------------------------------
SITE_URL ?= https://guide.premiereslignes.studio/
# Pages intérieures du PDF montrées en éventail sur l'image d'aperçu
OG_PAGES ?= 13 17
SITE_HOST = $(word 2,$(subst /, ,$(SITE_URL)))
CHROME   ?= $(shell command -v google-chrome || command -v chromium || command -v chromium-browser)

site: $(FONTS)
	test -f $(PDF) || { echo "Compilez d'abord le PDF (make ou make tectonic)"; exit 1; }
	mkdir -p docs/fonts
	cp $(PDF) docs/
	cp fonts/*.ttf docs/fonts/
	cp site/style.css docs/
	mkdir -p docs/img/youtube
	cp images/youtube/*.jpg docs/img/youtube/
	sed 's#{{SITE_URL}}#$(SITE_URL)#g' site/index.html > docs/index.html
	pdftoppm -r 110 -png -f 1 -l 1 -singlefile $(PDF) docs/couverture
	pdftoppm -r 90 -png -f $(word 1,$(OG_PAGES)) -l $(word 1,$(OG_PAGES)) -singlefile $(PDF) docs/_og-a
	pdftoppm -r 90 -png -f $(word 2,$(OG_PAGES)) -l $(word 2,$(OG_PAGES)) -singlefile $(PDF) docs/_og-b
	cp site/og-image.html docs/_og.html
	"$(CHROME)" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
	  --window-size=1200,630 --virtual-time-budget=3000 \
	  --screenshot=$(CURDIR)/docs/og-image.png file://$(CURDIR)/docs/_og.html 2>/dev/null
	rm -f docs/_og.html docs/_og-a.png docs/_og-b.png
	case "$(SITE_HOST)" in *.github.io) rm -f docs/CNAME ;; *) echo "$(SITE_HOST)" > docs/CNAME ;; esac
	touch docs/.nojekyll
	@echo "==> docs/ à jour pour $(SITE_URL)"

# Aperçu local du site sur http://localhost:8000 (Ctrl+C pour arrêter)
PORT ?= 8000
serve:
	@echo "==> http://127.0.0.1:$(PORT)"
	python3 -m http.server $(PORT) --bind 127.0.0.1 --directory docs

watch:
	latexmk -$(strip $(ENGINE)) -outdir=$(OUT) -interaction=nonstopmode -pvc $(MAIN).tex

fonts: $(FONTS)

fonts/AlfaSlabOne-Regular.ttf:
	curl -fsSL -o $@ $(GF)/alfaslabone/AlfaSlabOne-Regular.ttf
fonts/ZillaSlab-BoldItalic.ttf:
	curl -fsSL -o $@ $(GF)/zillaslab/ZillaSlab-BoldItalic.ttf
fonts/Lato-%.ttf:
	curl -fsSL -o $@ $(GF)/lato/Lato-$*.ttf

clean:
	latexmk -outdir=$(OUT) -c $(MAIN).tex || true

distclean:
	rm -rf $(OUT) $(PDF)
