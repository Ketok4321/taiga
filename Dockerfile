FROM fedora:38 as mutable
FROM quay.io/fedora-ostree-desktops/silverblue:38 as immutable

FROM mutable as console
RUN dnf install -y meson gcc gtk4-devel libadwaita-devel vte291-gtk4-devel libgtop2-devel gsettings-desktop-schemas-devel desktop-file-utils
WORKDIR console
COPY console .
RUN meson setup builddir --prefix /usr
RUN meson install -C builddir --destdir install

FROM mutable as extensions
RUN dnf install -y unzip jq
COPY install-ext /usr/local/bin/install-ext
WORKDIR extensions
ENV SHELL_VERSION=44
RUN install-ext blur-my-shell@aunetx
RUN install-ext lockkeys@vaina.lt
RUN install-ext clipboard-indicator@tudmotu.com 
RUN install-ext gtk3-theme-switcher@charlieqle
RUN install-ext user-theme@gnome-shell-extensions.gcampax.github.com
RUN install-ext custom-accent-colors@demiskp

FROM immutable 

RUN rpm-ostree install \
	distrobox \
	adw-gtk3-theme

RUN rpm-ostree override remove \
	firefox \
	firefox-langpacks

RUN rpm-ostree override remove \
	gnome-terminal \
	gnome-terminal-nautilus

RUN rpm-ostree install vte291-gtk4
COPY --from=console console/builddir/install /

RUN rpm-ostree override remove \
	gnome-classic-session \
	gnome-shell-extension-apps-menu	\
	gnome-shell-extension-launch-new-instance \
	gnome-shell-extension-places-menu \
	gnome-shell-extension-window-list \
	gnome-shell-extension-background-logo

COPY --from=extensions extensions /usr/share/gnome-shell/extensions

RUN rpm-ostree override remove \
	fedora-workstation-backgrounds \
	f38-backgrounds-gnome \
	f38-backgrounds-base \
	desktop-backgrounds-gnome \
	gnome-backgrounds

COPY backgrounds /usr/share/backgrounds/taiga
COPY gnome-background-properties /usr/share/gnome-background-properties
COPY dconf /etc/dconf/db/distro.d
RUN dconf update

RUN ostree container commit
