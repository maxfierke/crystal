-include Makefile.local # for optional local options e.g. threads

# Recipes for this Makefile

## Build the compiler
##   $ make
## Build the compiler with progress output
##   $ make progress=true
## Clean up built files then build the compiler
##   $ make clean crystal
## Build the compiler in release mode
##   $ make crystal release=1
## Run all specs in verbose mode
##   $ make spec verbose=1

CRYSTAL ?= crystal ## which previous crystal compiler use
LLVM_CONFIG ?=     ## llvm-config command path to use

release ?=      ## Compile in release mode
stats ?=        ## Enable statistics output
progress ?=     ## Enable progress output
threads ?=      ## Maximum number of threads to use
debug ?=        ## Add symbolic debug info
verbose ?=      ## Run specs in verbose mode
junit_output ?= ## Path to output junit results
static ?=       ## Enable static linking
target ?=       ## Target triple to compile Crystal for

LLVM_CONFIG := $(shell src/llvm/ext/find-llvm-config)

ifeq (${LLVM_CONFIG},)
  $(error Could not locate compatible llvm-config, make sure it is installed and in your PATH, or set LLVM_CONFIG. Compatible versions: $(shell cat src/llvm/ext/llvm-versions.txt))
else
  $(shell echo $(shell printf '\033[33m')Using $(LLVM_CONFIG) [version=$(shell $(LLVM_CONFIG) --version)]$(shell printf '\033[0m') >&2)
endif

LLVM_HOST_TARGET := $(shell $(LLVM_CONFIG) --host-target)
CRYSTAL_CONFIG_TARGET := $(shell src/llvm/ext/normalize-llvm-target $(if $(target),$(target),$(LLVM_HOST_TARGET)))
O := .build/$(CRYSTAL_CONFIG_TARGET)
SOURCES := $(shell find src -name '*.cr')
SPEC_SOURCES := $(shell find spec -name '*.cr')
SPEC_WARNINGS_OFF := --exclude-warnings spec/std --exclude-warnings spec/compiler
SPEC_FLAGS := $(if $(verbose),-v )$(if $(junit_output),--junit_output $(junit_output) )
CRYSTAL_CONFIG_LIBRARY_PATH := $(shell bin/crystal env CRYSTAL_LIBRARY_PATH 2> /dev/null)
CRYSTAL_CONFIG_BUILD_COMMIT := $(shell git rev-parse --short HEAD 2> /dev/null)
SOURCE_DATE_EPOCH := $(shell (git show -s --format=%ct HEAD || stat -c "%Y" Makefile || stat -f "%m" Makefile) 2> /dev/null)
EXPORTS := \
  CRYSTAL_CONFIG_LIBRARY_PATH="$(CRYSTAL_CONFIG_LIBRARY_PATH)" \
  CRYSTAL_CONFIG_BUILD_COMMIT="$(CRYSTAL_CONFIG_BUILD_COMMIT)" \
  CRYSTAL_CONFIG_TARGET="$(CRYSTAL_CONFIG_TARGET)" \
  SOURCE_DATE_EPOCH="$(SOURCE_DATE_EPOCH)"
SHELL = sh
LLVM_EXT_DIR = src/llvm/ext
LLVM_EXT_OBJ = $(LLVM_EXT_DIR)/$(CRYSTAL_CONFIG_TARGET)/llvm_ext.o
LIB_CRYSTAL_SOURCES = $(shell find src/ext -name '*.c')
LIB_CRYSTAL_OBJS = $(subst src/ext,src/ext/$(CRYSTAL_CONFIG_TARGET),$(subst .c,.o,$(LIB_CRYSTAL_SOURCES)))
LIB_CRYSTAL_TARGET = src/ext/$(CRYSTAL_CONFIG_TARGET)/libcrystal.a
DEPS = $(LLVM_EXT_OBJ) $(LIB_CRYSTAL_TARGET)
CFLAGS += -fPIC $(if $(debug),-g -O0) --target="$(CRYSTAL_CONFIG_TARGET)"
CXXFLAGS += $(if $(debug),-g -O0) --target="$(CRYSTAL_CONFIG_TARGET)"
LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags)
CRYSTAL_VERSION ?= $(shell cat src/VERSION)

override FLAGS += --target="$(CRYSTAL_CONFIG_TARGET)" $(if $(release),--release )$(if $(stats),--stats )$(if $(progress),--progress )$(if $(threads),--threads $(threads) )$(if $(debug),-d )$(if $(static),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

ifeq ($(shell command -v ld.lld >/dev/null && uname -s),Linux)
  EXPORT_CC ?= CC="cc -fuse-ld=lld"
endif

.PHONY: all
all: crystal ## Build all files (currently crystal only) [default]

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
		awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'

.PHONY: spec
spec: $(O)/all_spec ## Run all specs
	$(EXPORTS) $(O)/all_spec $(SPEC_FLAGS)

.PHONY: std_spec
std_spec: $(O)/std_spec ## Run standard library specs
	$(EXPORTS) $(O)/std_spec $(SPEC_FLAGS)

.PHONY: compiler_spec
compiler_spec: $(O)/compiler_spec ## Run compiler specs
	$(EXPORTS) $(O)/compiler_spec $(SPEC_FLAGS)

.PHONY: docs
docs: ## Generate standard library documentation
	./bin/crystal docs src/docs_main.cr $(DOCS_OPTIONS) --project-name=Crystal --project-version=$(CRYSTAL_VERSION) --source-refname=$(CRYSTAL_CONFIG_BUILD_COMMIT)

.PHONY: crystal
crystal: $(O)/crystal ## Build the compiler

.PHONY: deps llvm_ext libcrystal
deps: $(DEPS) ## Build dependencies

llvm_ext: $(LLVM_EXT_OBJ)
libcrystal: $(LIB_CRYSTAL_TARGET)

$(O)/all_spec: $(DEPS) $(SOURCES) $(SPEC_SOURCES)
	@mkdir -p $(O)
	$(EXPORT_CC) $(EXPORTS) ./bin/crystal build $(FLAGS) $(SPEC_WARNINGS_OFF) -o $@ spec/all_spec.cr

$(O)/std_spec: $(DEPS) $(SOURCES) $(SPEC_SOURCES)
	@mkdir -p $(O)
	$(EXPORT_CC) $(EXPORTS) ./bin/crystal build $(FLAGS) $(SPEC_WARNINGS_OFF) -o $@ spec/std_spec.cr

$(O)/compiler_spec: $(DEPS) $(SOURCES) $(SPEC_SOURCES)
	@mkdir -p $(O)
	$(EXPORT_CC) $(EXPORTS) ./bin/crystal build $(FLAGS) $(SPEC_WARNINGS_OFF) -o $@ spec/compiler_spec.cr

$(O)/crystal: $(DEPS) $(SOURCES)
	@mkdir -p $(O)
	$(EXPORTS) ./bin/crystal build $(FLAGS) -o $@ src/compiler/crystal.cr -D without_openssl -D without_zlib

src/ext/$(CRYSTAL_CONFIG_TARGET)/%.o: src/ext/%.c
	@mkdir -p $$(dirname $@)
	$(CC) -c $(CFLAGS) -o $@ $<

$(LLVM_EXT_OBJ): $(LLVM_EXT_DIR)/llvm_ext.cc
	@mkdir -p $$(dirname $@)
	$(CXX) -c $(CXXFLAGS) -o $@ $< $(shell $(LLVM_CONFIG) --cxxflags)

$(LIB_CRYSTAL_TARGET): $(LIB_CRYSTAL_OBJS)
	@mkdir -p $$(dirname $@)
	$(AR) -rcs $@ $^

.PHONY: clean
clean: clean_crystal ## Clean up built directories and files
	rm -rf $(LLVM_EXT_OBJ)
	rm -rf $(LIB_CRYSTAL_OBJS) $(LIB_CRYSTAL_TARGET)

.PHONY: clean_crystal
clean_crystal: ## Clean up crystal built files
	rm -rf $(O)
	rm -rf ./docs

.PHONY: clean_cache
clean_cache: ## Clean up CRYSTAL_CACHE_DIR files
	rm -rf $(shell ./bin/crystal env CRYSTAL_CACHE_DIR)
