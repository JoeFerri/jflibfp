# ------------------------------------------------------------
# MSYS2 UCRT64 (Windows 10)
# WSL2 Ubuntu 24.04 (Windows 10/11)
#
# Makefile for generating PasDoc + Graphviz documentation
# ------------------------------------------------------------


# =================================================================
# WSL ENVIRONMENTAL MONITORING
# =================================================================

OSRELEASE := $(shell cat /proc/sys/kernel/osrelease 2>/dev/null)
VERSION   := $(shell cat /proc/version 2>/dev/null)

IS_WSL_OSRELEASE := $(findstring microsoft,$(OSRELEASE))
IS_WSL_VERSION   := $(findstring microsoft,$(VERSION))

ifeq ($(strip $(IS_WSL_OSRELEASE)$(IS_WSL_VERSION)),)
    PASDOC_P  = pasdoc
    DOT_P     = dot
    BUILD_ENV = Native/Linux

    SEP = /
    PATH_ROOT_SRC = /
    PATH_ROOT_OPT = /
else
    PASDOC_P  = pasdoc.exe
    DOT_P     = dot.exe
    BUILD_ENV = WSL/Windows

    # Obtains the Linux CWD (e.g. /mnt/c/Users/...) and converts it to Windows format (e.g. C:\Users\...)
    PATH_WIN_ROOT := $(shell wslpath -w "$$(pwd)")

    SEP = \\

    PATH_ROOT_SRC = $(PATH_WIN_ROOT)
    PATH_ROOT_OPT = $(PATH_WIN_ROOT)
endif

$(info Environment detected: $(BUILD_ENV))
$(info PasDoc executable: $(PASDOC_P))
$(info Dot executable: $(DOT_P))
$(info Windows root path: $(PATH_WIN_ROOT))



# =================================================================
# OPERATIONS
# =================================================================

OUTDIR = docs
OUTDIR_WIN = $(PATH_ROOT_SRC)$(SEP)$(OUTDIR)

DOT_CLASSES = $(OUTDIR)/GVClasses.dot
DOT_USES    = $(OUTDIR)/GVUses.dot
PNG_CLASSES = $(OUTDIR)/GVClasses.png
PNG_USES    = $(OUTDIR)/GVUses.png

DOT_CLASSES_WIN = $(PATH_ROOT_SRC)$(SEP)$(OUTDIR)/GVClasses.dot
DOT_USES_WIN    = $(PATH_ROOT_SRC)$(SEP)$(OUTDIR)/GVUses.dot
PNG_CLASSES_WIN = $(PATH_ROOT_SRC)$(SEP)$(OUTDIR)/GVClasses.png
PNG_USES_WIN    = $(PATH_ROOT_SRC)$(SEP)$(OUTDIR)/GVUses.png

SRC = \
    "$(PATH_ROOT_SRC)$(SEP)project/src/consoleunit.pas" \
    "$(PATH_ROOT_SRC)$(SEP)project/src/formunit.pas" \
    "$(PATH_ROOT_SRC)$(SEP)project/src/iniunit.pas" \
    "$(PATH_ROOT_SRC)$(SEP)project/src/stateformunit.pas"



CSS    = style/pasdoc_custom.css
FOOTER = style/footer.html
AGPL_ICON = agplv3-with-text-100x42.png
AGPL_ICON_SOURCE = style/$(AGPL_ICON)
EXTERNAL_CH = external_class_hierarchy.txt

CSS_WIN    = $(PATH_ROOT_OPT)$(SEP)$(CSS)
FOOTER_WIN = $(PATH_ROOT_OPT)$(SEP)$(FOOTER)
EXTERNAL_CH_WIN = $(PATH_ROOT_OPT)$(SEP)$(EXTERNAL_CH)


DEFINES = --define FPC --define MSWINDOWS

PASDOC_OPTS = \
    --format html \
    --output "$(OUTDIR_WIN)" \
    --markdown \
    --auto-abstract \
    --marker=* \
    --link-gv-uses png \
    --link-gv-classes png \
    --graphviz-uses \
    --graphviz-classes \
    --verbosity 2 \
    --exclude-generator \
    --title "jflibfp Docs" \
    --footer "$(FOOTER_WIN)" \
    --css "$(CSS_WIN)" \
    --external-class-hierarchy="$(EXTERNAL_CH_WIN)"


$(OUTDIR):
	mkdir $(OUTDIR)

# PasDoc generates documentation + DOT files
doc: $(OUTDIR) $(FOOTER) $(CSS) 
	$(PASDOC_P) $(DEFINES) $(PASDOC_OPTS) $(SRC)
	cp "$(AGPL_ICON_SOURCE)" "$(OUTDIR)/$(AGPL_ICON)"

$(DOT_CLASSES): doc
$(DOT_USES): doc

# Convert DOT -> PNG with Graphviz
$(PNG_CLASSES): $(DOT_CLASSES)
	$(DOT_P) -Tpng "$(DOT_CLASSES_WIN)" -o "$(PNG_CLASSES_WIN)"

$(PNG_USES): $(DOT_USES)
	$(DOT_P) -Tpng "$(DOT_USES_WIN)" -o "$(PNG_USES_WIN)"

graphs: $(PNG_CLASSES) $(PNG_USES)


full-doc: doc graphs

all: full-doc


.PHONY: all clean doc graphs


clean:
	rm -rf $(OUTDIR)
