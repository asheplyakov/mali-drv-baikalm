

CC := $(CROSS)gcc
LIBS := libgbm.so.1.0.0
BLOBDIR := vendor/mali/bfkm_malit628_r26_linux_wayland
PREFIX ?= /usr
LIBDIR ?= lib64/mali

LDFLAGS += -Wl,-rpath -Wl,$(PREFIX)/$(LIBDIR)
CPPFLAGS += -I/usr/include/drm
CFLAGS ?= -O2 -Wall -pipe
BUILD ?= $(shell pwd)/.o

all: $(LIBS:%=$(BUILD)/%)

$(BUILD)/libgbm.so.1.0.0: $(BUILD)/src/gbm-wrapper.o
	$(CC) $(LDFLAGS) -shared -o $@ -Wl,-soname -Wl,libgbm.so.1 $< -L$(BLOBDIR) -lmali
	rm -f $(BUILD)/libgbm.so.1
	ln -s libgbm.so.1.0.0 $(BUILD)/libgbm.so.1
	rm -f $(BUILD)/libgbm.so
	ln -s libgbm.so.1 $(BUILD)/libgbm.so

$(BUILD)/src/gbm-wrapper.o: src/gbm-wrapper.c
	@mkdir -p "$(dir $@)"
	$(CC) -c -fPIC -DPIC $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(BUILD)/etc/ld.so.conf.d/mali.conf: Makefile
	mkdir -p "$(dir $@)"
	echo "$(PREFIX)/$(LIBDIR)" > $@.tmp
	mv $@.tmp $@

install: $(BUILD)/libgbm.so.1.0.0 $(BUILD)/etc/ld.so.conf.d/mali.conf
	install -m755 -d $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m644 $(BUILD)/libgbm.so.1.0.0 $(DESTDIR)$(PREFIX)/$(LIBDIR)
	rm -f $(DESTDIR)$(PREFIX)/$(LIBDIR)/libgbm.so.1
	rm -f $(DESTDIR)$(PREFIX)/$(LIBDIR)/libgbm.so
	ln -s libgbm.so.1 $(DESTDIR)$(PREFIX)/$(LIBDIR)/libgbm.so
	ln -s libgbm.so.1.0.0 $(DESTDIR)$(PREFIX)/$(LIBDIR)/libgbm.so.1
	install -m644 $(BLOBDIR)/libmali.so $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m644 $(BLOBDIR)/liboffline_compiler_api_gles.so $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m644 $(BLOBDIR)/libEGL.so.1 $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m644 $(BLOBDIR)/libGLESv2.so.2 $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m644 $(BLOBDIR)/libwayland-egl.so.1 $(DESTDIR)$(PREFIX)/$(LIBDIR)
	install -m755 -d $(DESTDIR)/etc/ld.so.conf.d
	install -m644 $(BUILD)/etc/ld.so.conf.d/mali.conf $(DESTDIR)/etc/ld.so.conf.d

clean:
	rm -rf $(BUILD)

