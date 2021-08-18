ARG kong_version
FROM kong:${kong_version} as base

USER root

ADD ./kong-plugin-reject-access-1.0-0.rockspec .
ADD ./src ./src

RUN luarocks make && luarocks pack kong-plugin-reject-access

RUN rm kong-plugin-reject-access-1.0-0.rockspec && rm -r src

FROM tianon/true

COPY --from=base ./kong-plugin-jwt-crafter-1.2-0.all.rock /
