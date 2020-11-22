# ------------------- builder stage
FROM ghcr.io/gentoo-docker-builds/gendev:latest as builder

# ------------------- emerge
RUN echo 'dev-python/* ~amd64' >> /etc/portage/package.accept_keywords
RUN emerge -C sandbox
RUN echo 'dev-python/awscli minimal python_targets_python3_7 xml ssl' >> /etc/portage/package.use/awscli
RUN ROOT=/awscli FEATURES='-usersandbox' emerge dev-python/awscli

# ------------------- shrink
RUN ROOT=/awscli emerge --quiet -C \
      app-admin/*\
      sys-apps/* \
      sys-kernel/* \
      virtual/* \
      sys-libs/ncurses

# ------------------- detox
RUN rm -rf \
        /awscli/var/db/pkg \
        /awscli/usr/share/doc \
        /awscli/usr/share/eselect \
        /awscli/usr/share/info \
        /awscli/usr/share/man \
        /awscli/var/lib/gentoo \
        /awscli/var/lib/portage \
        /awscli/var/cache/edb

# ------------------- empty image
FROM scratch
COPY --from=builder /awscli /
