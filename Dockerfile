# ------------------- builder stage
FROM gentoo/stage3-amd64 as builder
ENV FEATURES="-mount-sandbox -ipc-sandbox -network-sandbox -pid-sandbox -sandbox -usersandbox"

# ------------------- portage tree
COPY --from=gentoo/portage:latest /var/db/repos/gentoo /var/db/repos/gentoo

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

# ------------------- empty image
FROM scratch
COPY --from=builder /awscli /
