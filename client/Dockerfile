FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG                            SINGLER_HOME=/app
COPY .                       ${SINGLER_HOME}
RUN  chown -R nobody:nogroup ${SINGLER_HOME}
USER nobody
EXPOSE 4518
CMD [ "./up.sh" ]
