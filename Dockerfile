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
COPY usr /usr

# Gnome wallpapers depend on fedora wallpapers so it's not possible to remove them using rpm-ostree
RUN rm -rf \
	/usr/share/backgrounds/f38 \
	/usr/share/gnome-background-properties/f38.xml && \
	rpm-ostree override remove fedora-workstation-backgrounds

COPY backgrounds /usr/share/backgrounds/taiga
COPY gnome-background-properties /usr/share/gnome-background-properties
COPY 00-background /etc/dconf/db/distro.d/00-background
RUN dconf update

RUN ostree container commit
