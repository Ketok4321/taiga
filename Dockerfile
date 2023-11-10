ARG FEDORA_VERSION

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION} AS extensions
COPY install-ext /usr/local/bin/install-ext
WORKDIR extensions
ARG GNOME_VERSION
ENV SHELL_VERSION=$GNOME_VERSION
RUN install-ext blur-my-shell@aunetx
RUN install-ext lockkeys@vaina.lt
RUN install-ext clipboard-indicator@tudmotu.com 
RUN install-ext gtk3-theme-switcher@charlieqle
RUN install-ext user-theme@gnome-shell-extensions.gcampax.github.com
RUN install-ext custom-accent-colors@demiskp

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION}

RUN rpm-ostree install \
    vte291-gtk4 \
    gnome-console \
	distrobox \
	adw-gtk3-theme

ARG FEDORA_VERSION
RUN rpm-ostree override remove \
	firefox \
	firefox-langpacks \
	gnome-terminal \
	gnome-terminal-nautilus \
	gnome-classic-session \
	gnome-shell-extension-apps-menu	\
	gnome-shell-extension-launch-new-instance \
	gnome-shell-extension-places-menu \
	gnome-shell-extension-window-list \
	gnome-shell-extension-background-logo \
	fedora-workstation-backgrounds \
	f${FEDORA_VERSION}-backgrounds-gnome \
	f${FEDORA_VERSION}-backgrounds-base \
	desktop-backgrounds-gnome \
	gnome-backgrounds

COPY --from=extensions extensions /usr/share/gnome-shell/extensions

COPY backgrounds /usr/share/backgrounds/taiga
COPY gnome-background-properties /usr/share/gnome-background-properties
COPY dconf /etc/dconf/db/distro.d
RUN dconf update

RUN ostree container commit
