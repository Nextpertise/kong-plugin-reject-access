ARG kong_version
FROM kong:${kong_version}

USER root

ADD ./kong-plugin-reject-access-1.0-0.rockspec .
ADD ./src ./src

RUN luarocks make && luarocks pack kong-plugin-reject-access

RUN mkdir /artefact && mv ./kong-plugin-reject-access-1.0-0.all.rock /artefact/kong-plugin-reject-access-1.0-0.all.rock
RUN rm kong-plugin-reject-access-1.0-0.rockspec && rm -r src

USER kong
