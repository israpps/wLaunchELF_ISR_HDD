# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# Copyright 2001-2004, ps2dev - http://www.ps2dev.org
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.
#
# $Id$


IOP_CC_VERSION := $(shell $(IOP_CC) -dumpversion)

ASFLAGS_TARGET = -mcpu=r3000

ifeq ($(IOP_CC_VERSION),3.2.2)
ASFLAGS_TARGET = -march=r3000
endif

ifeq ($(IOP_CC_VERSION),3.2.3)
ASFLAGS_TARGET = -march=r3000
endif

IOP_INCS := $(IOP_INCS) -I$(PS2SDK)/iop/include -I$(PS2SDK)/common/include -Iinclude

IOP_CFLAGS  := -D_IOP -fno-builtin -O2 -G0 $(IOP_INCS) $(IOP_CFLAGS)
IOP_ASFLAGS := $(ASFLAGS_TARGET) -EL -G0 $(IOP_ASFLAGS)
IOP_LDFLAGS := -nostdlib $(IOP_LDFLAGS)

BIN2C = $(PS2SDK)/bin/bin2c
BIN2S = $(PS2SDK)/bin/bin2s
BIN2O = $(PS2SDK)/bin/bin2o

# Externally defined variables: IOP_BIN, IOP_OBJS, IOP_LIB

%.o : %.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

%.o : %.S
	$(IOP_CC) $(IOP_CFLAGS) $(IOP_INCS) -c $< -o $@

%.o : %.s
	$(IOP_AS) $(IOP_ASFLAGS) $< -o $@

#Rules for the PS2SDK-styled projects (objects in objs/, binary in bin/)
$(IOP_OBJS_DIR)%.o : $(IOP_SRC_DIR)%.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

$(IOP_OBJS_DIR)%.o : $(IOP_SRC_DIR)%.S
	$(IOP_CC) $(IOP_CFLAGS) $(IOP_INCS) -c $< -o $@

$(IOP_OBJS_DIR)%.o : $(IOP_SRC_DIR)%.s
	$(IOP_AS) $(IOP_ASFLAGS) $< -o $@

# A rule to build imports.lst.
$(IOP_OBJS_DIR)%.o : $(IOP_SRC_DIR)%.lst
	$(ECHO) "#include \"irx_imports.h\"" > $(IOP_OBJS_DIR)build-imports.c
	cat $< >> $(IOP_OBJS_DIR)build-imports.c
	$(IOP_CC) $(IOP_CFLAGS) -I$(IOP_SRC_DIR) -c $(IOP_OBJS_DIR)build-imports.c -o $@
	-rm -f $(IOP_OBJS_DIR)build-imports.c

# A rule to build exports.tab.
$(IOP_OBJS_DIR)%.o : $(IOP_SRC_DIR)%.tab
	$(ECHO) "#include \"irx.h\"" > $(IOP_OBJS_DIR)build-exports.c
	cat $< >> $(IOP_OBJS_DIR)build-exports.c
	$(IOP_CC) $(IOP_CFLAGS) -I$(IOP_SRC_DIR) -c $(IOP_OBJS_DIR)build-exports.c -o $@
	-rm -f $(IOP_OBJS_DIR)build-exports.c

$(IOP_OBJS_DIR):
	$(MKDIR) -p $(IOP_OBJS_DIR)

$(IOP_BIN_DIR):
	$(MKDIR) -p $(IOP_BIN_DIR)

$(IOP_LIB_DIR):
	$(MKDIR) -p $(IOP_LIB_DIR)

# A rule to build imports.lst.
%.o : %.lst
	$(ECHO) "#include \"irx_imports.h\"" > build-imports.c
	cat $< >> build-imports.c
	$(IOP_CC) $(IOP_CFLAGS) -I. -c build-imports.c -o $@
	-rm -f build-imports.c

# A rule to build exports.tab.
%.o : %.tab
	$(ECHO) "#include \"irx.h\"" > build-exports.c
	cat $< >> build-exports.c
	$(IOP_CC) $(IOP_CFLAGS) -I. -c build-exports.c -o $@
	-rm -f build-exports.c

$(IOP_BIN) : $(IOP_OBJS)
	$(IOP_CC) $(IOP_CFLAGS) -o $(IOP_BIN) $(IOP_OBJS) $(IOP_LDFLAGS) $(IOP_LIBS)

$(IOP_LIB) : $(IOP_OBJS)
	$(IOP_AR) cru $(IOP_LIB) $(IOP_OBJS)
