FROM fedora:38 as console
RUN dnf install -y meson gcc gtk4-devel libadwaita-devel vte291-gtk4-devel libgtop2-devel gsettings-desktop-schemas-devel desktop-file-utils
WORKDIR console
COPY console .
RUN meson setup builddir --prefix /usr
RUN meson install -C builddir --destdir install

FROM quay.io/fedora-ostree-desktops/silverblue:38 

RUN rpm-ostree override remove \
	gnome-terminal \
	gnome-terminal-nautilus \
	gnome-classic-session \
	gnome-shell-extension-apps-menu	\
	gnome-shell-extension-launch-new-instance \
	gnome-shell-extension-places-menu \
	gnome-shell-extension-window-list \
	gnome-shell-extension-background-logo

RUN rpm-ostree install vte291-gtk4
COPY --from=console console/builddir/install /

RUN rpm-ostree override remove \
	fedora-workstation-backgrounds \
	f38-backgrounds-gnome \
	f38-backgrounds-base \
	desktop-backgrounds-gnome \
	gnome-backgrounds

COPY backgrounds /usr/share/backgrounds/taiga
COPY gnome-background-properties /usr/share/gnome-background-properties
COPY 00-background /etc/dconf/db/distro.d/00-background
RUN dconf update

RUN ostree container commit
