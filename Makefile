# By default, recipe steps will be quieted.
# But a user can supply VERBOSE=1 as an environment variable or command line argument
# to re-enable build output.
VERBOSE ?= 0
ifeq ($(VERBOSE),1)
Q =
export VERBOSE = 1
else
Q = @
export VERBOSE = 0
endif

#
# The following options can be controlled on the command line
# by supplying a defintion, e.g.: make BUILDRESULTS=output/ DEBUG=1
#
BUILDRESULTS ?= buildresults
DEBUG ?= 1

LIBDIR:=$(BUILDRESULTS)/lib

CFLAGS = -Wall -Wextra -I include
STATIC_LIB_FLAGS = rcs
DEPFLAGS = -MT $@ -MMD -MP -MF $*.d
LDFLAGS += -Wl,-Map=buildresults/multifile-program-distributed.map
#LDFLAGS := -Wl,-Map=build_results/m-p-d.map

# By default, this Makefile produces release builds
ifeq ($(DEBUG),1)
CFLAGS += -Og
RELEASE_TYPE = 'DEBUG'
else
CFLAGS += -O2
RELEASE_TYPE = 'RELEASE'
endif

.PHONY: all
all: $(BUILDRESULTS)/multifile-program-distributed $(BUILDRESULTS)/multifile-program-distributed.zip
	@echo hello_world

APP_SOURCES := src/multifile_main.c
LIB_SOURCES := src/lib/multifile_func.c
LIB_OBJECTS := $(LIB_SOURCES:%.c=$(BUILDRESULTS)/%.o)
APP_OBJECTS := $(APP_SOURCES:%.c=$(BUILDRESULTS)/%.o)
DEPFILES := $(LIB_SOURCES:%.c=$(BUILDRESULTS)/%.d) $(APP_SOURCES:%.c=$(BUILDRESULTS)/%.d)

sourcefile = $(patsubst $(BUILDRESULTS)/%.o,%.c,$(1))

%.o: %.c
.SECONDEXPANSION:
%.o: $$(call sourcefile,$$@) %.d | $$(@D)
	$(Q)$(CC) $(LDFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

$(LIBDIR)/libmultifile_func.a: $(LIB_OBJECTS) | $(LIBDIR)
	$(Q)$(AR) $(STATIC_LIB_FLAGS) $@ $^

# This target is now purely a link step. Split into multiple lines due to length
$(BUILDRESULTS)/multifile-program-distributed:| $(BUILDRESULTS)
$(BUILDRESULTS)/multifile-program-distributed: $(LIBDIR)/libmultifile_func.a $(APP_OBJECTS)
$(BUILDRESULTS)/multifile-program-distributed:
	$(Q)$(CC) $(CFLAGS) $(LDFLAGS) $(APP_OBJECTS) -L$(LIBDIR) -lmultifile_func -o $@

$(BUILDRESULTS)/multifile-program-distributed.zip:
	@echo hello_world
	zip -r $(BUILDRESULTS)/multifile-program-distributed-$(RELEASE_TYPE).zip $(BUILDRESULTS)/multifile-program-distributed $(BUILDRESULTS)/multifile-program-distributed.map $(LIBDIR)\

clean:
	$(Q)$(RM) -r $(BUILDRESULTS)

$(patsubst %/,%,$(addprefix $(BUILDRESULTS)/,$(dir $(APP_SOURCES)))):
	$(Q)mkdir -p $@

$(patsubst %/,%,$(addprefix $(BUILDRESULTS)/,$(dir $(LIB_SOURCES)))):
	$(Q)mkdir -p $@

$(BUILDRESULTS):
	$(Q)mkdir -p $@

$(LIBDIR):
	$(Q)mkdir -p $@

$(DEPFILES):
include $(wildcard $(DEPFILES))
